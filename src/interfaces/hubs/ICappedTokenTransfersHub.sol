// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafeManageable} from 'interfaces/ISafeManageable.sol';

/**
 * @title ICappedTokenTransfersHub
 * @notice Interface for the CappedTokenTransfersHub contract
 */
interface ICappedTokenTransfersHub is ISafeManageable {
  /**
   * @notice Thrown when the cap is exceeded
   */
  error CapExceeded();

  /**
   * @notice Updates the state
   * @param _data The data to update the state with
   */
  function updateState(bytes memory _data) external;

  event NewChildCreated(address indexed _child);

  /**
   * @notice Gets the cap
   * @param _token The token to get the cap for
   * @return _cap The cap
   */
  function cap(address _token) external view returns (uint256 _cap);

  /**
   * @notice Gets the epoch length
   * @return _epochLength The epoch length
   */
  function EPOCH_LENGTH() external view returns (uint256 _epochLength);

  /**
   * @notice Gets the total amount of tokens spent
   * @param _token The token to get the total amount of tokens spent for
   * @return _totalSpent The total amount of tokens spent
   */
  function totalSpent(address _token) external view returns (uint256 _totalSpent);

  /**
   * @notice Gets the current epoch
   * @return _currentEpoch The current epoch
   */
  function currentEpoch() external view returns (uint256 _currentEpoch);

  /**
   * @notice Gets the starting timestamp
   * @return _startingTimestamp The starting timestamp
   */
  function startingTimestamp() external view returns (uint256 _startingTimestamp);
}
