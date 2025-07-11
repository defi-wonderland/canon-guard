// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ApproveActionFactory} from 'contracts/factories/ApproveActionFactory.sol';
import {ChangeSafeGuardActionFactory} from 'contracts/factories/ChangeSafeGuardActionFactory.sol';
import {DisapproveActionFactory} from 'contracts/factories/DisapproveActionFactory.sol';
import {IApproveAction} from 'interfaces/actions-builders/IApproveAction.sol';
import {IChangeSafeGuardAction} from 'interfaces/actions-builders/IChangeSafeGuardAction.sol';
import {IDisapproveAction} from 'interfaces/actions-builders/IDisapproveAction.sol';
import {IApproveActionFactory} from 'interfaces/factories/IApproveActionFactory.sol';
import {IChangeSafeGuardActionFactory} from 'interfaces/factories/IChangeSafeGuardActionFactory.sol';
import {IDisapproveActionFactory} from 'interfaces/factories/IDisapproveActionFactory.sol';
import {IntegrationEthereumBase} from 'test/integration/ethereum/IntegrationEthereumBase.sol';

contract IntegrationEntrypointManageActions is IntegrationEthereumBase {
  IApproveActionFactory public approveActionFactory;
  IApproveAction public approveAction;

  IDisapproveActionFactory public disapproveActionFactory;
  IDisapproveAction public disapproveAction;

  IChangeSafeGuardActionFactory public changeSafeGuardActionFactory;
  IChangeSafeGuardAction public changeSafeGuardAction;

  address public actionsBuilder;
  address public newSafeGuard;
  uint256 public constant APPROVAL_DURATION = 7 days;

  function setUp() public override {
    super.setUp();

    actionsBuilder = makeAddr('actionsBuilder');
    newSafeGuard = makeAddr('newSafeGuard');

    // Deploy the ApproveAction contract
    approveActionFactory = new ApproveActionFactory();
    approveAction = IApproveAction(
      approveActionFactory.createApproveAction(address(safeEntrypoint), address(actionsBuilder), APPROVAL_DURATION)
    );

    // Deploy the DisapproveAction contract
    disapproveActionFactory = new DisapproveActionFactory();
    disapproveAction = IDisapproveAction(
      disapproveActionFactory.createDisapproveAction(address(safeEntrypoint), address(actionsBuilder))
    );

    // Deploy the ChangeSafeGuardAction contract
    changeSafeGuardActionFactory = new ChangeSafeGuardActionFactory();
    changeSafeGuardAction = IChangeSafeGuardAction(
      changeSafeGuardActionFactory.createChangeSafeGuardAction(
        address(SAFE_PROXY), address(actionsBuilder), newSafeGuard
      )
    );
  }

  function test_ApproveActionsBuilder() public {
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

  function test_DisapproveActionsBuilder() public {
    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(address(disapproveAction));

    // Wait for the timelock period
    vm.warp(block.timestamp + LONG_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(address(disapproveAction));

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(address(disapproveAction));

    // Assert if the actions builder is approved
    assertEq(safeEntrypoint.approvalExpiries(address(actionsBuilder)), block.timestamp);
  }

  function test_ChangeSafeGuard() public {
    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(address(changeSafeGuardAction));

    // Wait for the timelock period
    vm.warp(block.timestamp + LONG_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(address(changeSafeGuardAction));

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(address(changeSafeGuardAction));

    // Assert if the safe guard is changed
    bytes32 _guardSlot = vm.load(address(SAFE_PROXY), keccak256('guard_manager.guard.address'));
    assertEq(address(uint160(uint256(_guardSlot))), newSafeGuard);
  }
}
