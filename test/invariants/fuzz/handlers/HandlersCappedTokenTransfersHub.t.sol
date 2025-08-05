// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ActionTarget, BaseHandlers} from './BaseHandlers.sol';
import {CappedTokenTransfers} from 'contracts/actions-builders/CappedTokenTransfers.sol';
import {ICappedTokenTransfersHub} from 'interfaces/action-hubs/ICappedTokenTransfersHub.sol';

abstract contract HandlersCappedTokenTransfersHub is BaseHandlers {
  // Track created hubs for testing
  mapping(address => uint256) public hubTokenCaps;
  mapping(address => address) public hubTokens; // hub -> token address
  address[] public createdHubs;

  function handler_executeTransaction_CappedTokenTransfersHub(uint256 _seed) public {
    if (ghost_hashes.length == 0) return;
    bytes32 _hash = ghost_hashes[_seed % ghost_hashes.length];

    address _actionsBuilder = ghost_hashToActionsBuilder[_hash];

    try safeEntrypoint.executeTransaction(_actionsBuilder) {
      // Successful execution - ActionTarget flags should be set
      // Cap verification is handled by the hub's updateState() function
      actionTarget = new ActionTarget();
    } catch Error(string memory _reason) {
      assertEq(_reason, 'GS020');
    } catch (bytes memory _reason) {
      assertTrue(
        bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))
          || bytes4(_reason) == bytes4(keccak256('NoTransactionQueued()'))
          || bytes4(_reason) == bytes4(keccak256('TransactionExpired()'))
          || bytes4(_reason) == bytes4(keccak256('CapExceeded()'))
      );

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

      if (bytes4(_reason) == bytes4(keccak256('CapExceeded()'))) {}
    }
  }

  function handler_createNewActionBuilderFromHub(
    uint256 _approvalDuration,
    uint256 _amount,
    uint256 _capMultiplier
  ) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _amount = bound(_amount, 1, 1_000_000);
    _capMultiplier = bound(_capMultiplier, 1, 5); // Cap will be 1x to 5x the amount

    // Setup tokens for the safe to transfer
    actionTarget.mint(address(safe), _amount);

    // Create a hub first with cap set higher than the amount (usually)
    address[] memory tokens = new address[](1);
    tokens[0] = address(actionTarget);
    uint256[] memory caps = new uint256[](1);
    caps[0] = _amount * _capMultiplier;

    address hub = cappedTokenTransfersHubFactory.createCappedTokenTransfersHub(
      address(safe), // safe
      address(signers[0]), // recipient
      tokens, // tokens
      caps, // caps
      1 days // epoch length
    );

    // Store the hub and its cap for later reference
    createdHubs.push(hub);
    hubTokenCaps[hub] = caps[0];
    hubTokens[hub] = address(actionTarget);

    // Create action builder through the hub's real createNewActionBuilder function
    vm.prank(signers[0]); // Must be safe owner
    try ICappedTokenTransfersHub(hub).createNewActionBuilder(address(actionTarget), _amount) returns (
      address actionsBuilder
    ) {
      vm.prank(address(safe));
      try safeEntrypoint.approveActionsBuilder(hub, _approvalDuration) {
        // Approve the hub, not the action builder
        vm.prank(signers[0]);
        safeEntrypoint.queueHubTransaction(hub, actionsBuilder); // Use queueHubTransaction

        bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(actionsBuilder);

        ghost_hashToActionsBuilder[_safeTxHash] = actionsBuilder;
        ghost_hashes.push(_safeTxHash);
        ghost_timestampOfActionQueued[_safeTxHash] = block.timestamp;
      } catch {
        assertGt(_approvalDuration, safeEntrypoint.MAX_APPROVAL_DURATION());
      }
    } catch {
      // Action builder creation might fail for various reasons
    }
  }

  function handler_queueCappedTokenTransfersFromHub(uint256 _approvalDuration, uint256 _amount) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _amount = bound(_amount, 1, 1_000_000);

    // Only proceed if we have created hubs
    if (createdHubs.length == 0) return;

    address hub = createdHubs[_amount % createdHubs.length];

    // Setup tokens for the safe to transfer
    actionTarget.mint(address(safe), _amount);

    // Create CappedTokenTransfers manually that references the hub
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
