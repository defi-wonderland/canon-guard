// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IOwnerManager} from '@safe-smart-account/interfaces/IOwnerManager.sol';
import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';
import {IRemoveOwnerAction} from 'interfaces/actions-builders/IRemoveOwnerAction.sol';

/**
 * @title RemoveOwnerAction
 * @notice Contract that builds an action to remove an owner with optional threshold decrease
 */
contract RemoveOwnerAction is IRemoveOwnerAction {
  /// @inheritdoc IRemoveOwnerAction
  address public immutable SAFE;

  /// @inheritdoc IRemoveOwnerAction
  address public immutable OWNER_TO_REMOVE;

  /// @inheritdoc IRemoveOwnerAction
  bool public immutable DECREASE_THRESHOLD;

  /**
   * @notice Constructor that sets up the RemoveOwnerAction contract
   * @param _safe The Safe contract address
   * @param _ownerToRemove The owner address to remove
   * @param _decreaseThreshold Whether to decrease the threshold when removing the owner
   */
  constructor(address _safe, address _ownerToRemove, bool _decreaseThreshold) {
    SAFE = _safe;
    OWNER_TO_REMOVE = _ownerToRemove;
    DECREASE_THRESHOLD = _decreaseThreshold;
  }

  // ~~~ ACTIONS METHODS ~~~

  /// @inheritdoc IActionsBuilder
  function getActions() external view returns (Action[] memory _actions) {
    _actions = new Action[](1);

    uint256 _currentThreshold = IOwnerManager(SAFE).getThreshold();
    uint256 _newThreshold = DECREASE_THRESHOLD ? _currentThreshold - 1 : _currentThreshold;

    address _prevOwner = _findPrevOwner();

    _actions[0] = Action({
      target: SAFE,
      data: abi.encodeCall(IOwnerManager.removeOwner, (_prevOwner, OWNER_TO_REMOVE, _newThreshold)),
      value: 0
    });
  }

  // ~~~ INTERNAL METHODS ~~~

  /**
   * @notice Finds the previous owner in the linked list
   * @return _prevOwner The previous owner address
   */
  function _findPrevOwner() internal view returns (address _prevOwner) {
    address _sentinel = address(0x1); // SENTINEL_OWNERS
    address[] memory _owners = IOwnerManager(SAFE).getOwners();
    uint256 _ownersLength = _owners.length;

    // Check if SENTINEL_OWNERS points to OWNER_TO_REMOVE (first owner)
    if (_ownersLength > 0 && _owners[0] == OWNER_TO_REMOVE) {
      return _sentinel;
    }

    // Traverse the linked list to find who points to OWNER_TO_REMOVE
    for (uint256 i = 0; i < _ownersLength - 1; i++) {
      if (_owners[i + 1] == OWNER_TO_REMOVE) {
        return _owners[i];
      }
    }

    revert OwnerNotFound();
  }
}
