// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ActionTarget, BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';

abstract contract HandlersAllowanceClaimor is BaseHandlers {
  address public immutable TOKEN_SENDER;
  address public immutable TOKEN_RECIPIENT;

  constructor() {
    TOKEN_SENDER = makeAddr('TOKEN_SENDER');
    TOKEN_RECIPIENT = makeAddr('TOKEN_RECIPIENT');
  }

  function handler_executeTransaction_AllowanceClaimor(uint256 _seed) public {
    if (ghost_hashes.length == 0) return;
    bytes32 _hash = ghost_hashes[_seed % ghost_hashes.length];

    address _actionsBuilder = ghost_hashToActionsBuilder[_hash];

    try safeEntrypoint.executeTransaction(_actionsBuilder) {
      assert(false);
      assertTrue(actionTarget.isTransferFromCalled());
      assertEq(actionTarget.transferFromSender(), TOKEN_SENDER);
      assertEq(actionTarget.transferFromRecipient(), TOKEN_RECIPIENT);
      assertEq(actionTarget.transferFromAmount(), 123_456); // allowance set in the erc20/action target contract

      actionTarget = new ActionTarget();
    } catch Error(string memory _reason) {
      assertEq(_reason, 'GS020');
    } catch (bytes memory _reason) {
      assertTrue(
        bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))
          || bytes4(_reason) == bytes4(keccak256('NoTransactionQueued()'))
          || bytes4(_reason) == bytes4(keccak256('TransactionExpired()'))
      );

      if (bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))) {
        if (ghost_approvedActionsBuilder[_actionsBuilder]) {
          assertGe(block.timestamp, ghost_timestampOfActionQueued[_hash] + safeEntrypoint.SHORT_TX_EXECUTION_DELAY());
        } else {
          assertGe(block.timestamp, ghost_timestampOfActionQueued[_hash] + safeEntrypoint.LONG_TX_EXECUTION_DELAY());
        }
      }

      if (bytes4(_reason) == bytes4(keccak256('TransactionExpired()'))) {
        if (ghost_approvedActionsBuilder[_actionsBuilder]) {
          assertLe(
            ghost_timestampOfActionQueued[_hash] + safeEntrypoint.SHORT_TX_EXECUTION_DELAY()
              + safeEntrypoint.TX_EXPIRY_DELAY(),
            block.timestamp
          );
        } else {
          assertLe(
            ghost_timestampOfActionQueued[_hash] + safeEntrypoint.LONG_TX_EXECUTION_DELAY()
              + safeEntrypoint.TX_EXPIRY_DELAY(),
            block.timestamp
          );
        }
      }
    }
  }

  function handler_queueAllowanceClaimor(uint256 _approvalDuration) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);

    address actionsBuilder = allowanceClaimorFactory.createAllowanceClaimor(
      address(safe), // safe
      address(actionTarget), // token
      TOKEN_SENDER, // token owner
      TOKEN_RECIPIENT // token recipient
    );

    vm.prank(signers[0]);
    safeEntrypoint.queueTransaction(actionsBuilder);

    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(actionsBuilder);

    ghost_hashToActionsBuilder[_safeTxHash] = actionsBuilder;
    ghost_hashes.push(_safeTxHash);
    ghost_timestampOfActionQueued[_safeTxHash] = block.timestamp;
  }
}
