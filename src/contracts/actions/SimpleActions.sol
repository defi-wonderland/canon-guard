// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions/IActionsBuilder.sol';
import {ISimpleActions} from 'interfaces/actions/ISimpleActions.sol';

/**
 * @title SimpleActions
 * @notice Contract that builds actions from simple actions
 */
contract SimpleActions is ISimpleActions {
  // ~~~ STORAGE ~~~

  /// @notice The array of actions
  Action[] internal _actions;

  // ~~~ CONSTRUCTOR ~~~

  /**
   * @notice Constructor that sets up the array of actions
   * @param _simpleActions The array of simple actions
   */
  constructor(SimpleAction[] memory _simpleActions) {
    uint256 _simpleActionsLength = _simpleActions.length;
    SimpleAction memory _simpleAction;
    Action memory _action;
    bytes4 _selector;
    bytes memory _completeCallData;

    for (uint256 _i; _i < _simpleActionsLength; ++_i) {
      _simpleAction = _simpleActions[_i];

      _selector = bytes4(keccak256(bytes(_simpleAction.signature)));
      _completeCallData = abi.encodePacked(_selector, _simpleAction.data);

      _action = Action({target: _simpleAction.target, data: _completeCallData, value: _simpleAction.value});

      _actions.push(_action);
      emit SimpleActionAdded(_simpleAction.target, _simpleAction.signature, _simpleAction.data, _simpleAction.value);
    }
  }

  // ~~~ ACTIONS METHODS ~~~

  /// @inheritdoc IActionsBuilder
  function getActions() external view returns (Action[] memory) {
    return _actions;
  }
}
