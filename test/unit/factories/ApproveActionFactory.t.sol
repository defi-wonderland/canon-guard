// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {ApproveActionFactory} from 'contracts/factories/ApproveActionFactory.sol';
import {Test} from 'forge-std/Test.sol';
import {IApproveAction} from 'interfaces/actions-builders/IApproveAction.sol';

contract UnitApproveActionFactorycreateApproveAction is Test {
  ApproveActionFactory public approveActionFactory;
  IApproveAction public auxApproveAction;

  function setUp() external {
    approveActionFactory = new ApproveActionFactory();
  }

  function test_WhenCalled(address _safeEntrypoint, address _actionsBuilder, uint256 _approvalDuration) external {
    address _approveAction =
      approveActionFactory.createApproveAction(_safeEntrypoint, _actionsBuilder, _approvalDuration);

    auxApproveAction =
      IApproveAction(deployCode('ApproveAction', abi.encode(_safeEntrypoint, _actionsBuilder, _approvalDuration)));

    // it should deploy an ApproveAction contract with correct args
    assertEq(address(auxApproveAction).code, _approveAction.code);

    // it should match the parameters sent to the constructor
    assertEq(IApproveAction(_approveAction).SAFE_ENTRYPOINT(), _safeEntrypoint);
    assertEq(IApproveAction(_approveAction).ACTIONS_BUILDER(), _actionsBuilder);
    assertEq(IApproveAction(_approveAction).APPROVAL_DURATION(), _approvalDuration);
  }
}
