// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/**
 * @title IAddOwnerWithThresholdActionFactory
 * @notice Interface for the AddOwnerWithThresholdActionFactory contract
 */
interface IAddOwnerWithThresholdActionFactory {
  // ~~~ FACTORY METHODS ~~~

  /**
   * @notice Creates an AddOwnerWithThresholdAction contract
   * @param _safe The Safe contract address
   * @param _newOwner The owner address to add
   * @param _increaseThreshold Whether to increase the threshold when adding the owner
   * @return _addOwnerWithThresholdAction The AddOwnerWithThresholdAction contract address
   */
  function createAddOwnerWithThresholdAction(
    address _safe,
    address _newOwner,
    bool _increaseThreshold
  ) external returns (address _addOwnerWithThresholdAction);
}
