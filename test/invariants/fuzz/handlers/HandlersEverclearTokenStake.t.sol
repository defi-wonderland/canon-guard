// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ActionTarget, BaseHandlers} from './BaseHandlers.sol';

abstract contract HandlersEverclearTokenStake is BaseHandlers {
  function handler_queueEverclearTokenStake(uint256 _approvalDuration, uint256 _lockTime) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _lockTime = bound(_lockTime, 1 days, 365 days);

    address actionsBuilder = everclearTokenStakeFactory.createEverclearTokenStake(
      address(actionTarget), // vesting escrow (actionTarget acts as all external contracts)
      address(actionTarget), // vesting wallet
      address(actionTarget), // spoke bridge
      address(actionTarget), // clear lockbox
      address(actionTarget), // next token
      address(actionTarget), // clear token
      address(safe), // safe
      _lockTime // lock time
    );

    vm.prank(address(safe));
    try safeEntrypoint.approveActionsBuilder(actionsBuilder, _approvalDuration) {
      vm.prank(signers[0]);
      try safeEntrypoint.queueTransaction(actionsBuilder) {
        bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(actionsBuilder);

        ghost_hashToActionsBuilder[_safeTxHash] = actionsBuilder;
        ghost_hashes.push(_safeTxHash);
        ghost_timestampOfActionQueued[_safeTxHash] = block.timestamp;
        ghost_actionsBuilderType[actionsBuilder] = ActionsBuilderType.EVERCLEAR_TOKEN_STAKE;
      } catch {
        // Queue might fail due to complex external dependencies
      }
    } catch {
      assertGt(_approvalDuration, safeEntrypoint.MAX_APPROVAL_DURATION());
    }
  }
}
