// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/**
 * @title IRemoveOwnerActionFactory
 * @notice Interface for the RemoveOwnerActionFactory contract
 */
interface IRemoveOwnerActionFactory {
  // ~~~ FACTORY METHODS ~~~

  /**
   * @notice Creates a RemoveOwnerAction contract
   * @param _safe The Safe contract address
   * @param _ownerToRemove The owner address to remove
   * @param _decreaseThreshold Whether to decrease the threshold when removing the owner
   * @return _removeOwnerAction The RemoveOwnerAction contract address
   */
  function createRemoveOwnerAction(
    address _safe,
    address _ownerToRemove,
    bool _decreaseThreshold
  ) external returns (address _removeOwnerAction);
}
