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

  function handler_createNewActionBuilderFromHub(
    uint256 _approvalDuration,
    uint256 _amount,
    uint256 _capMultiplier
  ) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _amount = bound(_amount, 1, 1_000_000);
    _capMultiplier = bound(_capMultiplier, 1, 5); // Cap will be 1x to 5x the amount

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
      ghost_timestampOfActionQueued[_safeTxHash] = block.timestamp;
      ghost_actionsBuilderType[actionsBuilder] = ActionsBuilderType.CAPPED_TOKEN_TRANSFERS_HUB;
    } catch {
      assertGt(_approvalDuration, safeEntrypoint.MAX_APPROVAL_DURATION());
    }
  }
}
