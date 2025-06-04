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

  struct TokenTransfer {
    address recipient;
    uint256 amount;
  }

  // ~~~ STORAGE METHODS ~~~

  function TOKEN() external view returns (address _token);
  function CAP() external view returns (uint256 _cap);
  function EPOCH_LENGTH() external view returns (uint256 _epochLength);

  function totalSpent() external view returns (uint256 _totalSpent);
  function currentEpoch() external view returns (uint256 _currentEpoch);
  function startingTimestamp() external view returns (uint256 _startingTimestamp);

  // ~~~ EVENTS ~~~

  // ~~~ ERRORS ~~~

  error CapExceeded();
  error InvalidAmount();
  error InvalidIndex();

  // ~~~ STATE MANAGEMENT ~~~

  function updateState(bytes memory _data) external;
}
