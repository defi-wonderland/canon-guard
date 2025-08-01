// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';
import {CappedTokenTransfers} from 'contracts/actions-builders/CappedTokenTransfers.sol';

abstract contract HandlersCappedTokenTransfers is BaseHandlers {
  function handler_executeTransaction_CappedTokenTransfers(uint256 _seed) public {
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

  function handler_queueCappedTokenTransfers(uint256 _approvalDuration, uint256 _amount) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _amount = bound(_amount, 1, 1_000_000);

    // Setup tokens for the safe to transfer
    actionTarget.mint(address(safe), _amount);

    // Create a hub first
    address[] memory tokens = new address[](1);
    tokens[0] = address(actionTarget);
    uint256[] memory caps = new uint256[](1);
    caps[0] = _amount * 2; // Set cap higher than transfer amount

    address hub = cappedTokenTransfersHubFactory.createCappedTokenTransfersHub(
      address(safe), // safe
      address(signers[0]), // recipient
      tokens, // tokens
      caps, // caps
      1 days // epoch length
    );

    // Create CappedTokenTransfers manually since there's no factory for it
    address actionsBuilder = address(
      new CappedTokenTransfers(
        address(actionTarget), // token
        _amount, // amount
        address(signers[0]), // recipient
        hub // hub
      )
    );

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
