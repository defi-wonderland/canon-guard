// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';
import {ISimpleTransfers} from 'interfaces/actions-builders/ISimpleTransfers.sol';

abstract contract HandlersSimpleTransfers is BaseHandlers {
  function handler_executeTransaction_SimpleTransfers(uint256 _seed) public {
    if (ghost_hashes.length == 0) return;
    bytes32 _hash = ghost_hashes[_seed % ghost_hashes.length];

    address _actionsBuilder = ghost_hashToActionsBuilder[_hash];

    try safeEntrypoint.executeTransaction(_actionsBuilder) {
      assertTrue(actionTarget.isTransferred());
      actionTarget.reset();
    } catch (bytes memory _reason) {
      assertTrue(
        bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))
          || bytes4(_reason) == bytes4(keccak256('NoTransactionQueued()'))
      );
    }
  }

  function handler_queueSimpleTransfers(uint256 _approvalDuration, uint256 _amount) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _amount = bound(_amount, 1, 1_000_000);

    // Setup tokens for the safe to transfer
    actionTarget.mint(address(safe), _amount);

    ISimpleTransfers.TransferAction[] memory _transferActions = new ISimpleTransfers.TransferAction[](1);
    _transferActions[0] =
      ISimpleTransfers.TransferAction({token: address(actionTarget), to: address(signers[0]), amount: _amount});

    address actionsBuilder = simpleTransfersFactory.createSimpleTransfers(_transferActions);

    vm.prank(address(safe));
    try safeEntrypoint.approveActionsBuilder(actionsBuilder, _approvalDuration) {
      vm.prank(signers[0]);
      safeEntrypoint.queueTransaction(actionsBuilder);

      bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(actionsBuilder);

      ghost_hashToActionsBuilder[_safeTxHash] = actionsBuilder;
      ghost_hashes.push(_safeTxHash);
    } catch {
      assertGt(_approvalDuration, safeEntrypoint.MAX_APPROVAL_DURATION());
    }
  }
}
