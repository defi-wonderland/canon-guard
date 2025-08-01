// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MockxERC20Lockbox} from '../utils/MockExternalContracts.sol';
import {BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';

abstract contract HandlersEverclearTokenConversion is BaseHandlers {
  MockxERC20Lockbox public mockLockbox;

  function _initializeEverclearMocks() internal {
    if (address(mockLockbox) == address(0)) {
      mockLockbox = new MockxERC20Lockbox(address(actionTarget), address(actionTarget));
    }
  }

  function handler_executeTransaction_EverclearTokenConversion(uint256 _seed) public {
    if (ghost_hashes.length == 0) return;
    bytes32 _hash = ghost_hashes[_seed % ghost_hashes.length];

    address _actionsBuilder = ghost_hashToActionsBuilder[_hash];

    try safeEntrypoint.executeTransaction(_actionsBuilder) {
      // Everclear conversion doesn't directly interact with actionTarget tracking
      actionTarget.reset();
    } catch (bytes memory _reason) {
      assertTrue(
        bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))
          || bytes4(_reason) == bytes4(keccak256('NoTransactionQueued()'))
      );
    }
  }

  function handler_queueEverclearTokenConversion(uint256 _approvalDuration, uint256 _amount) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _amount = bound(_amount, 1, 1_000_000);

    _initializeEverclearMocks();

    // Setup NEXT tokens for the safe
    actionTarget.mint(address(safe), _amount);

    address actionsBuilder = everclearTokenConversionFactory.createEverclearTokenConversion(
      address(mockLockbox), // lockbox
      address(actionTarget), // next token
      address(safe) // safe
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
