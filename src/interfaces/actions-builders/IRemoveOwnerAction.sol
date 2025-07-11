// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';

/**
 * @title IRemoveOwnerAction
 * @notice Interface for the RemoveOwnerAction contract
 */
interface IRemoveOwnerAction is IActionsBuilder {
  // ~~~ ERRORS ~~~

  /// @notice Error thrown when the owner to remove is not found
  error OwnerNotFound();

  // ~~~ STORAGE METHODS ~~~

  /**
   * @notice Gets the Safe contract address
   * @return _safe The Safe contract address
   */
  function SAFE() external view returns (address _safe);

  /**
   * @notice Gets the owner address to remove
   * @return _ownerToRemove The owner address to remove
   */
  function OWNER_TO_REMOVE() external view returns (address _ownerToRemove);

  /**
   * @notice Gets whether to decrease the threshold
   * @return _decreaseThreshold Whether to decrease the threshold
   */
  function DECREASE_THRESHOLD() external view returns (bool _decreaseThreshold);
}
