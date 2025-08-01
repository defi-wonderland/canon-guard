// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
  MockGateway,
  MockSpokeBridge,
  MockVestingEscrow,
  MockVestingWallet,
  MockxERC20Lockbox
} from '../utils/MockExternalContracts.sol';
import {BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';

abstract contract HandlersEverclearTokenStake is BaseHandlers {
  MockVestingEscrow public mockVestingEscrow;
  MockVestingWallet public mockVestingWallet;
  MockSpokeBridge public mockSpokeBridge;
  MockxERC20Lockbox public mockClearLockbox;
  MockGateway public mockGateway;

  function _initializeEverclearStakeMocks() internal {
    if (address(mockVestingEscrow) == address(0)) {
      mockGateway = new MockGateway();
      mockSpokeBridge = new MockSpokeBridge(address(mockGateway));
      mockVestingEscrow = new MockVestingEscrow();
      mockVestingWallet = new MockVestingWallet();
      mockClearLockbox = new MockxERC20Lockbox(address(actionTarget), address(actionTarget));
    }
  }

  function handler_executeTransaction_EverclearTokenStake(uint256 _seed) public {
    if (ghost_hashes.length == 0) return;
    bytes32 _hash = ghost_hashes[_seed % ghost_hashes.length];

    address _actionsBuilder = ghost_hashToActionsBuilder[_hash];

    try safeEntrypoint.executeTransaction(_actionsBuilder) {
      // Everclear staking doesn't directly interact with actionTarget tracking
      actionTarget.reset();
    } catch (bytes memory _reason) {
      assertTrue(
        bytes4(_reason) == bytes4(keccak256('TransactionNotYetExecutable()'))
          || bytes4(_reason) == bytes4(keccak256('NoTransactionQueued()'))
          || bytes4(_reason) == bytes4(keccak256('EvmError: Revert'))
      );
    }
  }

  function handler_queueEverclearTokenStake(uint256 _approvalDuration, uint256 _lockTime) public {
    _approvalDuration = bound(_approvalDuration, 1, 1000);
    _lockTime = bound(_lockTime, 1 days, 365 days);

    _initializeEverclearStakeMocks();

    // Setup tokens for the safe and vesting contracts
    actionTarget.mint(address(mockVestingWallet), 1000);
    actionTarget.mint(address(safe), 1000);

    address actionsBuilder = everclearTokenStakeFactory.createEverclearTokenStake(
      address(mockVestingEscrow), // vesting escrow
      address(mockVestingWallet), // vesting wallet
      address(mockSpokeBridge), // spoke bridge
      address(mockClearLockbox), // clear lockbox
      address(actionTarget), // next token
      address(actionTarget), // clear token (using same for simplicity)
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
      } catch {
        // Queue might fail due to complex external dependencies
      }
    } catch {
      assertGt(_approvalDuration, safeEntrypoint.MAX_APPROVAL_DURATION());
    }
  }
}
