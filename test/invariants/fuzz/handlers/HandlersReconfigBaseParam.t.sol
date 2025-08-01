// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ActionTarget, BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';

/// Reconfigure the short/long delay or expiry delay
/// As these are immutable parameters, it needs a redeployment
abstract contract HandlersReconfigBaseParam is BaseHandlers {
  function handler_changeShortTxDelay(uint256 _shortTxExecutionDelay) public {
    _shortTxExecutionDelay = bound(_shortTxExecutionDelay, 1, safeEntrypoint.LONG_TX_EXECUTION_DELAY());

    // get current params
    uint256 _longTxExecutionDelay = safeEntrypoint.LONG_TX_EXECUTION_DELAY();
    uint256 _txExpiryDelay = safeEntrypoint.TX_EXPIRY_DELAY();
    uint256 _maxApprovalDuration = safeEntrypoint.MAX_APPROVAL_DURATION();
    address _emergencyTrigger = safeEntrypoint.emergencyTrigger();
    address _emergencyCaller = safeEntrypoint.emergencyCaller();

    // redeploy with same params except new delay
    safeEntrypoint = SafeEntrypoint(
      safeEntrypointFactory.createSafeEntrypoint(
        address(safe),
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );

    // set the new entrypoint as guard
    vm.prank(address(safe));
    safe.setGuard(address(safeEntrypoint));
  }

  function handler_changeLongTxDelay(uint256 _longTxExecutionDelay) public {
    _longTxExecutionDelay = bound(_longTxExecutionDelay, safeEntrypoint.SHORT_TX_EXECUTION_DELAY(), 3650 days);

    // get current params
    uint256 _shortTxExecutionDelay = safeEntrypoint.SHORT_TX_EXECUTION_DELAY();
    uint256 _txExpiryDelay = safeEntrypoint.TX_EXPIRY_DELAY();
    uint256 _maxApprovalDuration = safeEntrypoint.MAX_APPROVAL_DURATION();
    address _emergencyTrigger = safeEntrypoint.emergencyTrigger();
    address _emergencyCaller = safeEntrypoint.emergencyCaller();

    // redeploy with same params except new delay
    safeEntrypoint = SafeEntrypoint(
      safeEntrypointFactory.createSafeEntrypoint(
        address(safe),
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );

    // set the new entrypoint as guard
    vm.prank(address(safe));
    safe.setGuard(address(safeEntrypoint));
  }

  function handler_changeTxExpiryDelay(uint256 _txExpiryDelay) public {
    _txExpiryDelay = bound(_txExpiryDelay, 1, 3650 days);

    // get current params
    uint256 _shortTxExecutionDelay = safeEntrypoint.SHORT_TX_EXECUTION_DELAY();
    uint256 _longTxExecutionDelay = safeEntrypoint.LONG_TX_EXECUTION_DELAY();
    uint256 _maxApprovalDuration = safeEntrypoint.MAX_APPROVAL_DURATION();
    address _emergencyTrigger = safeEntrypoint.emergencyTrigger();
    address _emergencyCaller = safeEntrypoint.emergencyCaller();

    // redeploy with same params except new delay
    safeEntrypoint = SafeEntrypoint(
      safeEntrypointFactory.createSafeEntrypoint(
        address(safe),
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );

    // set the new entrypoint as guard
    vm.prank(address(safe));
    safe.setGuard(address(safeEntrypoint));
  }

  function handler_changeMaxApprovalDuration(uint256 _maxApprovalDuration) public {
    // get current params
    uint256 _shortTxExecutionDelay = safeEntrypoint.SHORT_TX_EXECUTION_DELAY();
    uint256 _longTxExecutionDelay = safeEntrypoint.LONG_TX_EXECUTION_DELAY();
    uint256 _txExpiryDelay = safeEntrypoint.TX_EXPIRY_DELAY();
    address _emergencyTrigger = safeEntrypoint.emergencyTrigger();
    address _emergencyCaller = safeEntrypoint.emergencyCaller();

    // redeploy with same params except new delay
    safeEntrypoint = SafeEntrypoint(
      safeEntrypointFactory.createSafeEntrypoint(
        address(safe),
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );

    // set the new entrypoint as guard
    vm.prank(address(safe));
    safe.setGuard(address(safeEntrypoint));
  }
}
