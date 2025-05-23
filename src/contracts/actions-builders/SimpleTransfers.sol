// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';
import {ISimpleTransfers} from 'interfaces/actions-builders/ISimpleTransfers.sol';

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

/**
 * @title SimpleTransfers
 * @notice Contract that builds actions from token transfer actions
 */
contract SimpleTransfers is ISimpleTransfers {
  // ~~~ STORAGE ~~~

  /// @notice The array of actions
  Action[] internal _actions;

  // ~~~ CONSTRUCTOR ~~~

  /**
   * @notice Constructor that sets up the array of actions
   * @param _transferActions The array of transfer actions
   */
  constructor(TransferAction[] memory _transferActions) {
    uint256 _transferActionsLength = _transferActions.length;
    TransferAction memory _transferAction;
    Action memory _action;

    for (uint256 _i; _i < _transferActionsLength; ++_i) {
      _transferAction = _transferActions[_i];

      _action = Action({
        target: _transferAction.token,
        data: abi.encodeCall(IERC20.transfer, (_transferAction.to, _transferAction.amount)),
        value: 0
      });

      _actions.push(_action);
      emit TransferActionAdded(_transferAction.token, _transferAction.to, _transferAction.amount);
    }
  }

  // ~~~ ACTIONS METHODS ~~~

  /// @inheritdoc IActionsBuilder
  function getActions() external view returns (Action[] memory) {
    return _actions;
  }
}
