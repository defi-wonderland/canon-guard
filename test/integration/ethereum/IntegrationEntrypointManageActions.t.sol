// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {AddOwnerWithThresholdActionFactory} from 'contracts/factories/AddOwnerWithThresholdActionFactory.sol';
import {ApproveActionFactory} from 'contracts/factories/ApproveActionFactory.sol';
import {ChangeSafeGuardActionFactory} from 'contracts/factories/ChangeSafeGuardActionFactory.sol';
import {DisapproveActionFactory} from 'contracts/factories/DisapproveActionFactory.sol';
import {RemoveOwnerActionFactory} from 'contracts/factories/RemoveOwnerActionFactory.sol';
import {IAddOwnerWithThresholdAction} from 'interfaces/actions-builders/IAddOwnerWithThresholdAction.sol';
import {IApproveAction} from 'interfaces/actions-builders/IApproveAction.sol';
import {IChangeSafeGuardAction} from 'interfaces/actions-builders/IChangeSafeGuardAction.sol';
import {IDisapproveAction} from 'interfaces/actions-builders/IDisapproveAction.sol';
import {IRemoveOwnerAction} from 'interfaces/actions-builders/IRemoveOwnerAction.sol';
import {IAddOwnerWithThresholdActionFactory} from 'interfaces/factories/IAddOwnerWithThresholdActionFactory.sol';
import {IApproveActionFactory} from 'interfaces/factories/IApproveActionFactory.sol';
import {IChangeSafeGuardActionFactory} from 'interfaces/factories/IChangeSafeGuardActionFactory.sol';
import {IDisapproveActionFactory} from 'interfaces/factories/IDisapproveActionFactory.sol';
import {IRemoveOwnerActionFactory} from 'interfaces/factories/IRemoveOwnerActionFactory.sol';
import {IntegrationEthereumBase} from 'test/integration/ethereum/IntegrationEthereumBase.sol';

contract IntegrationEntrypointManageActions is IntegrationEthereumBase {
  IApproveActionFactory public approveActionFactory;
  IApproveAction public approveAction;

  IDisapproveActionFactory public disapproveActionFactory;
  IDisapproveAction public disapproveAction;

  IChangeSafeGuardActionFactory public changeSafeGuardActionFactory;
  IChangeSafeGuardAction public changeSafeGuardAction;

  IAddOwnerWithThresholdActionFactory public addOwnerWithThresholdActionFactory;
  IAddOwnerWithThresholdAction public addOwnerWithThresholdAction;

  IRemoveOwnerActionFactory public removeOwnerActionFactory;
  IRemoveOwnerAction public removeOwnerAction;

  address public actionsBuilder;
  address public newSafeGuard;
  address public newOwner;
  address public ownerToRemove;
  bool public increaseThreshold;
  bool public decreaseThreshold;

  uint256 public constant APPROVAL_DURATION = 7 days;

  function setUp() public override {
    super.setUp();

    actionsBuilder = makeAddr('actionsBuilder');
    newSafeGuard = makeAddr('newSafeGuard');
    newOwner = makeAddr('newOwner');
    ownerToRemove = _safeOwners[0]; // Remove first owner
    increaseThreshold = true;
    decreaseThreshold = true;

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

    // Deploy the AddOwnerWithThresholdAction contract
    addOwnerWithThresholdActionFactory = new AddOwnerWithThresholdActionFactory();
    addOwnerWithThresholdAction = IAddOwnerWithThresholdAction(
      addOwnerWithThresholdActionFactory.createAddOwnerWithThresholdAction(
        address(SAFE_PROXY), newOwner, increaseThreshold
      )
    );

    // Deploy the RemoveOwnerAction contract
    removeOwnerActionFactory = new RemoveOwnerActionFactory();
    removeOwnerAction = IRemoveOwnerAction(
      removeOwnerActionFactory.createRemoveOwnerAction(address(SAFE_PROXY), ownerToRemove, decreaseThreshold)
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

  function test_AddOwnerWithThresholdIncreaseThreshold() public {
    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(address(addOwnerWithThresholdAction));

    // Wait for the timelock period
    vm.warp(block.timestamp + LONG_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(address(addOwnerWithThresholdAction));

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(address(addOwnerWithThresholdAction));

    // Assert if the owner is added
    assertEq(SAFE_PROXY.isOwner(newOwner), true);
    assertEq(SAFE_PROXY.getThreshold(), _safeThreshold + 1);
  }

  function test_AddOwnerWithThresholdMantainThreshold() public {
    addOwnerWithThresholdAction = IAddOwnerWithThresholdAction(
      addOwnerWithThresholdActionFactory.createAddOwnerWithThresholdAction(address(SAFE_PROXY), newOwner, false)
    );

    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(address(addOwnerWithThresholdAction));

    // Wait for the timelock period
    vm.warp(block.timestamp + LONG_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(address(addOwnerWithThresholdAction));

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(address(addOwnerWithThresholdAction));

    // Assert if the owner is added
    assertEq(SAFE_PROXY.isOwner(newOwner), true);
    assertEq(SAFE_PROXY.getThreshold(), _safeThreshold);
  }

  function test_RemoveOwnerDecreaseThreshold() public {
    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(address(removeOwnerAction));

    // Wait for the timelock period
    vm.warp(block.timestamp + LONG_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(address(removeOwnerAction));

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(address(removeOwnerAction));

    // Assert if the owner is removed
    assertEq(SAFE_PROXY.isOwner(ownerToRemove), false);
    assertEq(SAFE_PROXY.getThreshold(), _safeThreshold - 1);
  }

  function test_RemoveOwnerMantainThreshold() public {
    removeOwnerAction =
      IRemoveOwnerAction(removeOwnerActionFactory.createRemoveOwnerAction(address(SAFE_PROXY), ownerToRemove, false));

    // Queue the transaction
    vm.prank(_safeOwners[0]);
    safeEntrypoint.queueTransaction(address(removeOwnerAction));

    // Wait for the timelock period
    vm.warp(block.timestamp + LONG_TX_EXECUTION_DELAY);

    // Get the Safe transaction hash
    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(address(removeOwnerAction));

    // Approve the Safe transaction hash
    for (uint256 _i; _i < _safeThreshold; ++_i) {
      vm.startPrank(_safeOwners[_i]);
      SAFE_PROXY.approveHash(_safeTxHash);
    }
    vm.stopPrank();

    // Execute the transaction
    safeEntrypoint.executeTransaction(address(removeOwnerAction));

    // Assert if the owner is removed
    assertEq(SAFE_PROXY.isOwner(ownerToRemove), false);
    assertEq(SAFE_PROXY.getThreshold(), _safeThreshold);
  }
}
