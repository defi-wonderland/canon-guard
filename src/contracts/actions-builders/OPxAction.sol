// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ISafeManageable} from 'interfaces/ISafeManageable.sol';
import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';
import {IOPxAction} from 'interfaces/actions-builders/IOPxAction.sol';
import {IOPx} from 'interfaces/external/IOPx.sol';

/**
 * @title OPxAction
 * @notice Contract that builds the actions for OPx
 */
contract OPxAction is IOPxAction {
  // ~~~ STORAGE ~~~

  /// @inheritdoc IOPxAction
  address public immutable OPx;

  // ~~~ CONSTRUCTOR ~~~

  /**
   * @notice Constructor that sets up the OPx contract address
   * @param _opx The OPx contract address
   */
  constructor(address _opx) {
    OPx = _opx;
  }

  // ~~~ ACTIONS METHODS ~~~

  /// @inheritdoc IActionsBuilder
  function getActions() external view returns (Action[] memory _actions) {
    uint256 _balance = IERC20(OPx).balanceOf(_getSenderFromEntrypoint());

    _actions = new Action[](1);
    _actions[0] = Action({target: OPx, data: abi.encodeCall(IOPx.downgrade, (_balance)), value: 0});
  }

  /**
   * @notice Get the sender from the entrypoint.
   * @dev Assuming msg.sender is a SafeEntrypoint (because getActions() will be called when calling queueTransaction()),
   * we can get the sender from the Safe contract.
   * @return _sender The sender address
   */
  function _getSenderFromEntrypoint() internal view returns (address _sender) {
    _sender = address(ISafeManageable(msg.sender).SAFE());
  }
}
