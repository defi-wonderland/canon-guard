// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';

/**
 * @title IAddOwnerWithThresholdAction
 * @notice Interface for the AddOwnerWithThresholdAction contract
 */
interface IAddOwnerWithThresholdAction is IActionsBuilder {
  // ~~~ STORAGE METHODS ~~~

  /**
   * @notice Gets the Safe contract address
   * @return _safe The Safe contract address
   */
  function SAFE() external view returns (address _safe);

  /**
   * @notice Gets the new owner address to add
   * @return _newOwner The new owner address to add
   */
  function NEW_OWNER() external view returns (address _newOwner);

  /**
   * @notice Gets whether to increase the threshold
   * @return _increaseThreshold Whether to increase the threshold
   */
  function INCREASE_THRESHOLD() external view returns (bool _increaseThreshold);
}
