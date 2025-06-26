// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafeEntrypoint, SafeEntrypoint} from 'contracts/SafeEntrypoint.sol';

contract SafeEntrypointForTest is SafeEntrypoint {
  constructor(
    address _safe,
    address _multiSendCallOnly,
    uint256 _shortTxExecutionDelay,
    uint256 _longTxExecutionDelay,
    uint256 _txExpiryDelay
  ) SafeEntrypoint(_safe, _multiSendCallOnly, _shortTxExecutionDelay, _longTxExecutionDelay, _txExpiryDelay) {}

  // Mock functions to directly manipulate storage
  function mockTransaction(
    address _actionsBuilder,
    bytes memory _actionsData,
    uint256 _executableAt,
    uint256 _expiresAt
  ) external {
    queuedTransactions[_actionsBuilder] =
      ISafeEntrypoint.TransactionInfo({actionsData: _actionsData, executableAt: _executableAt, expiresAt: _expiresAt});
  }

  function mockApprovalExpiry(address _actionsBuilder, uint256 _expiry) external {
    approvalExpiries[_actionsBuilder] = _expiry;
  }
}
