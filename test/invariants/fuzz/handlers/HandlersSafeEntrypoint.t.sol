// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ActionTarget, BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';

/// Handlers for general SafeEntrypoint and Safe interactions
abstract contract HandlersSafeEntrypoint is BaseHandlers {
  /// Approve an actions builder (bypass the signature check itself/prank the safe)
  function handler_approveActionsBuilder(uint256 _seed, uint256 _approvalDuration) public {
    _approvalDuration = bound(_approvalDuration, 1, 10_000);

    if (ghost_hashes.length == 0) return;
    bytes32 _hash = ghost_hashes[_seed % ghost_hashes.length];

    address _actionsBuilder = ghost_hashToActionsBuilder[_hash];

    vm.prank(address(safe));
    try safeEntrypoint.approveActionsBuilder(_actionsBuilder, _approvalDuration) {
      ghost_approvedActionsBuilder[_actionsBuilder] = true;
    } catch {
      assertGt(_approvalDuration, safeEntrypoint.MAX_APPROVAL_DURATION());
    }
  }

  /// Handler to approve a hash, by one of the signers (we don't assess the signature validation itself,
  /// as its done by the Safe itself)
  function handler_approveHash(uint256 _signerSeed, uint256 _hashSeed) public usingSigner(_signerSeed) {
    if (ghost_hashes.length == 0) return; // avoid mod 0
    bytes32 _hash = ghost_hashes[_hashSeed % ghost_hashes.length];

    try safe.approveHash(_hash) {
      // Hash approval is part of Safe, we don't track it here
    } catch {
      assertEq(_hash, bytes32(0));
    }
  }

  /// Reconfigure the short/long delay or expiry delay
  /// As these are immutable parameters, it needs a redeployment
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
