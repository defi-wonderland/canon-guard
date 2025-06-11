// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafeManageable} from 'interfaces/ISafeManageable.sol';
import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';

/**
 * @title ICappedTokenTransfers
 * @notice Interface for the CappedTokenTransfers contract
 */
interface ICappedTokenTransfers is ISafeManageable, IActionsBuilder {
  // ~~~ STRUCTS ~~~

  /**
   * @notice Struct for a token transfer
   * @param recipient The recipient address
   * @param amount The amount of tokens to transfer
   */
  struct TokenTransfer {
    address recipient;
    uint256 amount;
  }

  // ~~~ ERRORS ~~~

  /**
   * @notice Thrown when the cap is exceeded
   */
  error CapExceeded();

  /**
   * @notice Thrown when the amount is invalid
   */
  error InvalidAmount();

  /**
   * @notice Thrown when the index is invalid
   */
  error InvalidIndex();

  // ~~~ ADMIN METHODS ~~~

  /**
   * @notice Adds a token transfer
   * @param _recipient The recipient address
   * @param _amount The amount of tokens to transfer
   */
  function addTokenTransfer(address _recipient, uint256 _amount) external;

  /**
   * @notice Removes a token transfer
   * @param _index The index of the token transfer
   */
  function removeTokenTransfer(uint256 _index) external;

  // ~~~ STATE MANAGEMENT ~~~

  /**
   * @notice Updates the state
   * @param _data The data to update the state with
   */
  function updateState(bytes memory _data) external;

  // ~~~ STORAGE METHODS ~~~

  /**
   * @notice Gets the token contract
   * @return _token The token contract address
   */
  function TOKEN() external view returns (address _token);

  /**
   * @notice Gets the cap
   * @return _cap The cap
   */
  function CAP() external view returns (uint256 _cap);

  /**
   * @notice Gets the epoch length
   * @return _epochLength The epoch length
   */
  function EPOCH_LENGTH() external view returns (uint256 _epochLength);

  /**
   * @notice Gets the total amount of tokens spent
   * @return _totalSpent The total amount of tokens spent
   */
  function totalSpent() external view returns (uint256 _totalSpent);

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

  /**
   * @notice Gets the token transfers
   * @param _index The index of the token transfer
   * @return _recipient The recipient address
   * @return _amount The amount of tokens to transfer
   */
  function tokenTransfers(uint256 _index) external view returns (address _recipient, uint256 _amount);
}
