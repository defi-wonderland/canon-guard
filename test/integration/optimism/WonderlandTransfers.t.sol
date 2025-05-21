// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISimpleTransfers} from 'interfaces/actions/ISimpleTransfers.sol';

import {IntegrationOptimismBase} from 'test/integration/optimism/IntegrationOptimismBase.sol';

contract IntegrationWonderlandTransfers is IntegrationOptimismBase {
  // ~~~ ACTIONS ~~~
  address internal _actionsBuilder;
  address internal _bonusesPullSplit = 0x689b5182a50e76Efab2076865C1242E69Ec74E4e;

  function setUp() public override {
    super.setUp();

    // Deploy the SimpleTransfers contract
    ISimpleTransfers.Transfer memory _bonusesTransfer =
      ISimpleTransfers.Transfer({token: address(KITE), to: _bonusesPullSplit, amount: _safeBalance});

    ISimpleTransfers.Transfer[] memory _simpleTransfers = new ISimpleTransfers.Transfer[](1);
    _simpleTransfers[0] = _bonusesTransfer;

    _actionsBuilder = simpleTransfersFactory.createSimpleTransfers(_simpleTransfers);
  }

  function test_ExecuteTransaction() public {
    // Allow the SafeEntrypoint to call the SimpleTransfers contract
    uint256 _approvalDuration = block.timestamp + 1 days;

    vm.prank(address(SAFE_PROXY));
    safeEntrypoint.approveActionsBuilder(_actionsBuilder, _approvalDuration);

    // Queue the transaction
    vm.prank(_safeOwners[0]);
    uint256 _txId = safeEntrypoint.queueTransaction(_actionsBuilder, DEFAULT_TX_EXPIRY_DELAY);

    // Wait for the timelock period
    vm.warp(block.timestamp + SHORT_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(_txId);

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(_txId);

    // Assert the token balances
    assertEq(KITE.balanceOf(_bonusesPullSplit), _safeBalance);
    assertEq(KITE.balanceOf(address(SAFE_PROXY)), 0);
  }
}
