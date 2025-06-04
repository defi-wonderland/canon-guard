// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {SafeManageable} from 'contracts/SafeManageable.sol';

import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';
import {ICappedTokenTransfers} from 'interfaces/actions-builders/ICappedTokenTransfers.sol';

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

/**
 * @title CappedTokenTransfers
 * @notice Contract that builds actions from capped token transfers
 */
contract CappedTokenTransfers is SafeManageable, ICappedTokenTransfers {
  // ~~~ STORAGE ~~~

  // Token configuration
  /// @inheritdoc ICappedTokenTransfers
  address public immutable TOKEN;
  /// @inheritdoc ICappedTokenTransfers
  uint256 public immutable CAP;
  /// @inheritdoc ICappedTokenTransfers
  uint256 public immutable EPOCH_LENGTH;

  // State tracking
  /// @inheritdoc ICappedTokenTransfers
  uint256 public totalSpent;
  /// @inheritdoc ICappedTokenTransfers
  uint256 public currentEpoch;
  /// @inheritdoc ICappedTokenTransfers
  uint256 public startingTimestamp;

  // ~~~ CONSTRUCTOR ~~~

  /**
   * @notice Constructor that sets up the Safe, token, cap, epoch length and starting timestamp
   * @param _safe The Gnosis Safe contract address
   * @param _token The token contract address
   * @param _cap The cap for the token transfers
   * @param _epochLength The epoch length for the token transfers
   */
  constructor(address _safe, address _token, uint256 _cap, uint256 _epochLength) SafeManageable(_safe) {
    TOKEN = _token;
    CAP = _cap;
    EPOCH_LENGTH = _epochLength;
    startingTimestamp = block.timestamp;
  }

  // ~~~ STATE MANAGEMENT ~~~

  /// @inheritdoc ICappedTokenTransfers
  function updateState(bytes memory _data) external isSafe {
    uint256 _currentEpoch = (block.timestamp - startingTimestamp) / EPOCH_LENGTH;

    // If we're in a new epoch, reset the spending
    if (_currentEpoch > currentEpoch) {
      totalSpent = 0;
      currentEpoch = _currentEpoch;
    }

    uint256 _amount = abi.decode(_data, (uint256));
    uint256 _totalSpent = totalSpent + _amount;

    if (_totalSpent > CAP) {
      revert CapExceeded();
    }

    totalSpent = _totalSpent;
  }

  // ~~~ ACTIONS METHODS ~~~

  /// @inheritdoc IActionsBuilder
  function getActions(bytes memory _data) external view returns (Action[] memory _actions) {
    TokenTransfer[] memory _tokenTransfers = abi.decode(_data, (TokenTransfer[]));

    // Create actions array: one for each valid transfer + one for updateState
    _actions = new Action[](_tokenTransfers.length + 1);
    // Initialize the total amount counter
    uint256 _totalAmount = 0;
    // Add token transfers to the actions array
    uint256 _actionIndex = 0;
    for (uint256 i = 0; i < _tokenTransfers.length; i++) {
      uint256 _amount = _tokenTransfers[i].amount;
      _totalAmount += _amount;
      _actions[_actionIndex] = Action({
        target: TOKEN,
        data: abi.encodeCall(IERC20.transfer, (_tokenTransfers[i].recipient, _amount)),
        value: 0
      });
      _actionIndex++;
    }

    // Last action: update state
    _actions[_actionIndex] = Action({
      target: address(this),
      data: abi.encodeCall(ICappedTokenTransfers.updateState, (abi.encode(_totalAmount))),
      value: 0
    });

    return _actions;
  }
}
