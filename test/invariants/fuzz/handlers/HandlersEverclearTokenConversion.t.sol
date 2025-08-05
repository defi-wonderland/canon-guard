// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ActionTarget, BaseHandlers} from './BaseHandlers.sol';

abstract contract HandlersEverclearTokenConversion is BaseHandlers {
  function handler_queueEverclearTokenConversion(uint256 _approvalDuration, uint256 _amount) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _amount = bound(_amount, 1, 1_000_000);

    address actionsBuilder = everclearTokenConversionFactory.createEverclearTokenConversion(
      TOKEN_SENDER, // lockbox
      address(actionTarget), // next token
      TOKEN_RECIPIENT // safe
    );

    vm.prank(address(safe));
    try safeEntrypoint.approveActionsBuilder(actionsBuilder, _approvalDuration) {
      vm.prank(signers[0]);
      safeEntrypoint.queueTransaction(actionsBuilder);

      bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(actionsBuilder);

      ghost_hashToActionsBuilder[_safeTxHash] = actionsBuilder;
      ghost_hashes.push(_safeTxHash);
      ghost_timestampOfActionQueued[_safeTxHash] = block.timestamp;
      ghost_actionsBuilderType[actionsBuilder] = ActionsBuilderType.EVERCLEAR_TOKEN_CONVERSION;
    } catch {
      assertGt(_approvalDuration, safeEntrypoint.MAX_APPROVAL_DURATION());
    }
  }
}
