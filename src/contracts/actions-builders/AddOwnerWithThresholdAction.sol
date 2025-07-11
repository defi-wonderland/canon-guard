// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IOwnerManager} from '@safe-smart-account/interfaces/IOwnerManager.sol';
import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';
import {IAddOwnerWithThresholdAction} from 'interfaces/actions-builders/IAddOwnerWithThresholdAction.sol';

/**
 * @title AddOwnerWithThresholdAction
 * @notice Contract that builds an action to add an owner with optional threshold increase
 */
contract AddOwnerWithThresholdAction is IAddOwnerWithThresholdAction {
  /// @inheritdoc IAddOwnerWithThresholdAction
  address public immutable SAFE;

  /// @inheritdoc IAddOwnerWithThresholdAction
  address public immutable NEW_OWNER;

  /// @inheritdoc IAddOwnerWithThresholdAction
  bool public immutable INCREASE_THRESHOLD;

  /**
   * @notice Constructor that sets up the AddOwnerWithThresholdAction contract
   * @param _safe The Safe contract address
   * @param _newOwner The owner address to add
   * @param _increaseThreshold Whether to increase the threshold when adding the owner
   */
  constructor(address _safe, address _newOwner, bool _increaseThreshold) {
    SAFE = _safe;
    NEW_OWNER = _newOwner;
    INCREASE_THRESHOLD = _increaseThreshold;
  }

  // ~~~ ACTIONS METHODS ~~~

  /// @inheritdoc IActionsBuilder
  function getActions() external view returns (Action[] memory _actions) {
    _actions = new Action[](1);

    uint256 _currentThreshold = IOwnerManager(SAFE).getThreshold();
    uint256 _newThreshold = INCREASE_THRESHOLD ? _currentThreshold + 1 : _currentThreshold;

    _actions[0] = Action({
      target: SAFE,
      data: abi.encodeCall(IOwnerManager.addOwnerWithThreshold, (NEW_OWNER, _newThreshold)),
      value: 0
    });
  }
}
