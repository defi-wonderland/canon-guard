// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';

import {SimpleActionsFactory} from 'contracts/factories/SimpleActionsFactory.sol';
import {ISimpleActions} from 'interfaces/actions-builders/ISimpleActions.sol';

abstract contract HandlersSimpleActions is BaseHandlers {
  function handler_executeTransaction_SimpleActions(uint256 _seed) public {
    if (ghost_hashes.length == 0) return;
    bytes32 _hash = ghost_hashes[_seed % ghost_hashes.length];

    address _actionsBuilder = ghost_hashToActionsBuilder[_hash];

    try safeEntrypoint.executeTransaction(_actionsBuilder) {
      assertTrue(actionTarget.isDeposited());
      assertTrue(actionTarget.isTransferred());
      actionTarget.reset();
    } catch (bytes memory _reason) {
      assertTrue(
        bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))
          || bytes4(_reason) == bytes4(keccak256('NoTransactionQueued()'))
      );
    }
  }

  function handler_queueSimpleAction(uint256 _approvalDuration) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);

    ISimpleActions.SimpleAction memory _depositAction =
      ISimpleActions.SimpleAction({target: address(actionTarget), signature: 'deposit()', data: bytes(''), value: 0});
    ISimpleActions.SimpleAction memory _transferAction = ISimpleActions.SimpleAction({
      target: address(actionTarget),
      signature: 'transfer(address,uint256)',
      data: abi.encode(address(signers[0]), 1),
      value: 0
    });

    ISimpleActions.SimpleAction[] memory _simpleActions = new ISimpleActions.SimpleAction[](2);
    _simpleActions[0] = _depositAction;
    _simpleActions[1] = _transferAction;

    address actionsBuilder = simpleActionsFactory.createSimpleActions(_simpleActions);

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
