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

  function handler_executeTransaction(uint256 _seed) public {
    if (ghost_hashes.length == 0) return;

    bytes32 _hash = ghost_hashes[_seed % ghost_hashes.length];
    address _actionsBuilder = ghost_hashToActionsBuilder[_hash];

    actionTarget = new ActionTarget();

    try safeEntrypoint.executeTransaction(_actionsBuilder) {
      _assertPostCondition(_actionsBuilder);
    } catch Error(string memory _reason) {
      assertEq(_reason, 'GS020');
    } catch (bytes memory _reason) {
      assertTrue(_isTimingError(_reason));
      _assertTimingError(_reason, _actionsBuilder);
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

  function _isTimingError(bytes memory _reason) internal pure returns (bool) {
    return (
      bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))
        || bytes4(_reason) == bytes4(keccak256('NoTransactionQueued()'))
        || bytes4(_reason) == bytes4(keccak256('TransactionExpired()'))
    );
  }

  function _assertTimingError(bytes memory _reason, address _actionsBuilder) internal {
    if (bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))) {
      (, uint256 _executableAt,) = safeEntrypoint.queuedTransactions(_actionsBuilder);
      assertLe(block.timestamp, _executableAt);
    }

    if (bytes4(_reason) == bytes4(keccak256('TransactionExpired()'))) {
      (,, uint256 _expireAt) = safeEntrypoint.queuedTransactions(_actionsBuilder);
      assertGe(block.timestamp, _expireAt);
    }
  }

  function _assertPostCondition(address _actionsBuilder) internal {
    if (ghost_actionsBuilderType[_actionsBuilder] == ActionsBuilderType.ALLOWANCE_CLAIMOR) {
      assertTrue(actionTarget.isTransferFromCalled());
      assertEq(actionTarget.transferFromSender(), TOKEN_SENDER);
      assertEq(actionTarget.transferFromRecipient(), TOKEN_RECIPIENT);
      // min between allowance and sender balance (see ActionTarget contract - balance is 123, allowance is 789)
      assertEq(actionTarget.transferFromAmount(), 123);
    } else if (ghost_actionsBuilderType[_actionsBuilder] == ActionsBuilderType.SIMPLE_ACTIONS) {
      assertTrue(actionTarget.isDepositCalled());
      assertTrue(actionTarget.isTransferCalled());
      assertEq(actionTarget.transferRecipient(), TOKEN_RECIPIENT);
      assertEq(actionTarget.transferAmount(), AMOUNT);
    } else if (ghost_actionsBuilderType[_actionsBuilder] == ActionsBuilderType.SIMPLE_TRANSFERS) {
      assertTrue(actionTarget.isTransferCalled());
      assertEq(actionTarget.transferRecipient(), TOKEN_RECIPIENT);
      assertEq(actionTarget.transferAmount(), AMOUNT);
    } else if (ghost_actionsBuilderType[_actionsBuilder] == ActionsBuilderType.OPX_ACTION) {
      assertTrue(actionTarget.isDowngraded());
      assertEq(actionTarget.downgradeAmount(), 123);
    } else if (ghost_actionsBuilderType[_actionsBuilder] == ActionsBuilderType.EVERCLEAR_TOKEN_CONVERSION) {
      assertTrue(actionTarget.isApproved());
      assertEq(actionTarget.approveSpender(), TOKEN_RECIPIENT);
      assertEq(actionTarget.approveAmount(), 123);
      assertTrue(actionTarget.isERC20Deposited());
      assertEq(actionTarget.depositAmount(), 123);
    } else if (ghost_actionsBuilderType[_actionsBuilder] == ActionsBuilderType.EVERCLEAR_TOKEN_STAKE) {
      assertTrue(actionTarget.isClaimed());
      assertEq(actionTarget.claimRecipient(), TOKEN_RECIPIENT);
      assertTrue(actionTarget.isReleased());
      assertTrue(actionTarget.isApproved());
      assertEq(actionTarget.approveSpender(), TOKEN_RECIPIENT);
      assertEq(actionTarget.approveAmount(), 123);
      assertTrue(actionTarget.isIncreaseLockPositionCalled());
      assertEq(actionTarget.lockPositionAmount(), 123);
      assertEq(actionTarget.lockTime(), 123);
      assertEq(actionTarget.gasLimit(), 123);
      assertTrue(actionTarget.isUpdateStateCalled());
      assertEq(actionTarget.updateStateData(), abi.encode(123, 123));
    } else if (ghost_actionsBuilderType[_actionsBuilder] == ActionsBuilderType.CAPPED_TOKEN_TRANSFERS_HUB) {
      assertTrue(actionTarget.isTransferCalled());
      assertEq(actionTarget.transferRecipient(), TOKEN_RECIPIENT);
      assertEq(actionTarget.transferAmount(), AMOUNT);
    }
  }
}
