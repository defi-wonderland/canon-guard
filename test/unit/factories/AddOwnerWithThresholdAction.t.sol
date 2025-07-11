// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {AddOwnerWithThresholdActionFactory} from 'contracts/factories/AddOwnerWithThresholdActionFactory.sol';
import {Test} from 'forge-std/Test.sol';
import {IAddOwnerWithThresholdAction} from 'interfaces/actions-builders/IAddOwnerWithThresholdAction.sol';

contract UnitAddOwnerWithThresholdActionFactorycreateAddOwnerWithThresholdAction is Test {
  AddOwnerWithThresholdActionFactory public addOwnerWithThresholdActionFactory;
  IAddOwnerWithThresholdAction public auxAddOwnerWithThresholdAction;

  function setUp() external {
    addOwnerWithThresholdActionFactory = new AddOwnerWithThresholdActionFactory();
  }

  function test_WhenCalled(address _safe, address _newOwner, bool _increaseThreshold) external {
    address _addOwnerWithThresholdAction =
      addOwnerWithThresholdActionFactory.createAddOwnerWithThresholdAction(_safe, _newOwner, _increaseThreshold);

    auxAddOwnerWithThresholdAction = IAddOwnerWithThresholdAction(
      deployCode('AddOwnerWithThresholdAction', abi.encode(_safe, _newOwner, _increaseThreshold))
    );

    // it should deploy a AddOwnerWithThresholdAction
    assertEq(address(auxAddOwnerWithThresholdAction).code, _addOwnerWithThresholdAction.code);

    // it should match the parameters sent to the constructor
    assertEq(IAddOwnerWithThresholdAction(_addOwnerWithThresholdAction).SAFE(), _safe);
    assertEq(IAddOwnerWithThresholdAction(_addOwnerWithThresholdAction).NEW_OWNER(), _newOwner);
    assertEq(IAddOwnerWithThresholdAction(_addOwnerWithThresholdAction).INCREASE_THRESHOLD(), _increaseThreshold);
  }
}
