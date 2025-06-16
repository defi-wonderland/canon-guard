// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {EverclearTokenConversion} from 'src/contracts/actions-builders/EverclearTokenConversion.sol';
import {IntegrationEthereumBase} from 'test/integration/ethereum/IntegrationEthereumBase.sol';

contract IntegrationEverclearConversion is IntegrationEthereumBase {
  // ~~~ ACTIONS ~~~
  address internal _actionsBuilder;
  address internal _clearLockbox = 0x22f424Bca11FE154c403c277b5F8dAb54a4bA29b;
  address internal _next = 0xFE67A4450907459c3e1FFf623aA927dD4e28c67a;
  address internal _clear = 0x58b9cB810A68a7f3e1E4f8Cb45D1B9B3c79705E8;

  function setUp() public override {
    super.setUp();

    // Deploy the contract
    _actionsBuilder = address(new EverclearTokenConversion(_clearLockbox, _next, address(SAFE_PROXY)));
  }

  function test_ExecuteTransaction() public {
    assertEq(NEXT.balanceOf(address(SAFE_PROXY)), _safeBalance);
    assertEq(CLEAR.balanceOf(address(SAFE_PROXY)), _safeBalance);

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

    // Assert the token balances. All NEXT was converted to CLEAR
    assertEq(NEXT.balanceOf(address(SAFE_PROXY)), 0);
    assertEq(CLEAR.balanceOf(address(SAFE_PROXY)), _safeBalance * 2);
  }
}
