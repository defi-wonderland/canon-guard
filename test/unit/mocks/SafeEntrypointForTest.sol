// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafeEntrypoint, SafeEntrypoint} from 'contracts/SafeEntrypoint.sol';

contract SafeEntrypointForTest is SafeEntrypoint {
  constructor(
    address _safe,
    address _multiSendCallOnly,
    uint256 _shortTxExecutionDelay,
    uint256 _longTxExecutionDelay,
    uint256 _txExpiryDelay,
    address _emergencyTrigger,
    address _emergencyCaller
  )
    SafeEntrypoint(
      _safe,
      _multiSendCallOnly,
      _shortTxExecutionDelay,
      _longTxExecutionDelay,
      _txExpiryDelay,
      _emergencyTrigger,
      _emergencyCaller
    )
  {}

  // Mock functions to directly manipulate storage
  function mockTransaction(
    uint256 _txId,
    address _actionsBuilder,
    bytes memory _actionsData,
    uint256 _executableAt,
    uint256 _expiresAt,
    bool _isExecuted
  ) external {
    transactions[_txId] = ISafeEntrypoint.TransactionInfo({
      actionsBuilder: _actionsBuilder,
      actionsData: _actionsData,
      executableAt: _executableAt,
      expiresAt: _expiresAt,
      isExecuted: _isExecuted
    });
  }

  function mockApprovalExpiry(address _actionsBuilder, uint256 _expiry) external {
    approvalExpiries[_actionsBuilder] = _expiry;
  }
}
