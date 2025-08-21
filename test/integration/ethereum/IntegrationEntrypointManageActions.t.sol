// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ApproveActionFactory} from 'contracts/factories/ApproveActionFactory.sol';
import {IApproveAction} from 'interfaces/actions-builders/IApproveAction.sol';
import {IApproveActionFactory} from 'interfaces/factories/IApproveActionFactory.sol';
import {IntegrationEthereumBase} from 'test/integration/ethereum/IntegrationEthereumBase.sol';

contract IntegrationEntrypointManageActions is IntegrationEthereumBase {
  // IApproveActionFactory public approveActionFactory;
  IApproveAction public approveAction;

  address public actionsBuilder;
  uint256 public constant APPROVAL_DURATION = 7 days;

  function setUp() public override {
    super.setUp();

    actionsBuilder = makeAddr('actionsBuilder');

    // Deploy the ApproveAction contract
    approveActionFactory = new ApproveActionFactory();
    approveAction = IApproveAction(
      approveActionFactory.createApproveAction(address(safeEntrypoint), address(actionsBuilder), APPROVAL_DURATION)
    );
  }

  function test_ApproveActionsBuilderOrHub() public {
    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(address(approveAction));

    // Wait for the timelock period
    vm.warp(block.timestamp + LONG_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(address(approveAction));

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(address(approveAction));

    // Assert if the actions builder is approved
    assertEq(safeEntrypoint.approvalExpiries(address(actionsBuilder)), block.timestamp + APPROVAL_DURATION);
  }
}
