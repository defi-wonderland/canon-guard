// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {ISafeManageable} from 'interfaces/ISafeManageable.sol';
import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';
import {IEverclearTokenConversion} from 'interfaces/actions-builders/IEverclearTokenConversion.sol';
import {IxERC20Lockbox} from 'interfaces/external/IxERC20Lockbox.sol';

/**
 * @title EverclearTokenConversion
 * @notice Contract that exchanges NEXT for CLEAR
 */
contract EverclearTokenConversion is IEverclearTokenConversion {
  // ~~~ STORAGE ~~~

  /// @inheritdoc IEverclearTokenConversion
  IxERC20Lockbox public immutable CLEAR_LOCKBOX;

  /// @inheritdoc IEverclearTokenConversion
  IERC20 public immutable NEXT;

  // ~~~ CONSTRUCTOR ~~~

  /**
   * @notice Constructor that sets up the xERC20Lockbox and NEXT
   * @param _lockbox The xERC20Lockbox contract address
   * @param _next The NEXT contract address
   */
  constructor(address _lockbox, address _next) {
    CLEAR_LOCKBOX = IxERC20Lockbox(_lockbox);
    NEXT = IERC20(_next);
  }

  // ~~~ ACTIONS METHODS ~~~

  /// @inheritdoc IActionsBuilder
  function getActions() external view returns (Action[] memory _actions) {
    uint256 _amount = NEXT.balanceOf(_getSenderFromEntrypoint());

    _actions = new Action[](2);
    _actions[0] =
      Action({target: address(NEXT), data: abi.encodeCall(IERC20.approve, (address(CLEAR_LOCKBOX), _amount)), value: 0});
    _actions[1] =
      Action({target: address(CLEAR_LOCKBOX), data: abi.encodeCall(IxERC20Lockbox.deposit, (_amount)), value: 0});
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
