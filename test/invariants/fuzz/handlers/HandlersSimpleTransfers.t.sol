// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ActionTarget, BaseHandlers} from './BaseHandlers.sol';
import {ISimpleTransfers} from 'interfaces/actions-builders/ISimpleTransfers.sol';

abstract contract HandlersSimpleTransfers is BaseHandlers {
  function handler_queueSimpleTransfers(uint256 _approvalDuration) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);

    ISimpleTransfers.TransferAction[] memory _transferActions = new ISimpleTransfers.TransferAction[](1);
    _transferActions[0] =
      ISimpleTransfers.TransferAction({token: address(actionTarget), to: TOKEN_RECIPIENT, amount: AMOUNT});

    address actionsBuilder = simpleTransfersFactory.createSimpleTransfers(_transferActions);

    vm.prank(address(safe));
    try safeEntrypoint.approveActionsBuilder(actionsBuilder, _approvalDuration) {
      vm.prank(signers[0]);
      safeEntrypoint.queueTransaction(actionsBuilder);

      bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(actionsBuilder);

      ghost_hashToActionsBuilder[_safeTxHash] = actionsBuilder;
      ghost_hashes.push(_safeTxHash);
      ghost_timestampOfActionQueued[_safeTxHash] = block.timestamp;
      ghost_actionsBuilderType[actionsBuilder] = ActionsBuilderType.SIMPLE_TRANSFERS;
    } catch {
      assertGt(_approvalDuration, safeEntrypoint.MAX_APPROVAL_DURATION());
    }
  }
}
