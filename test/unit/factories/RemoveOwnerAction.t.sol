// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {RemoveOwnerActionFactory} from 'contracts/factories/RemoveOwnerActionFactory.sol';
import {Test} from 'forge-std/Test.sol';
import {IRemoveOwnerAction} from 'interfaces/actions-builders/IRemoveOwnerAction.sol';

contract UnitRemoveOwnerActionFactorycreateRemoveOwnerAction is Test {
  RemoveOwnerActionFactory public removeOwnerActionFactory;
  IRemoveOwnerAction public auxRemoveOwnerAction;

  function setUp() external {
    removeOwnerActionFactory = new RemoveOwnerActionFactory();
  }

  function test_WhenCalled(address _safe, address _ownerToRemove, bool _decreaseThreshold) external {
    address _removeOwnerAction =
      removeOwnerActionFactory.createRemoveOwnerAction(_safe, _ownerToRemove, _decreaseThreshold);

    auxRemoveOwnerAction =
      IRemoveOwnerAction(deployCode('RemoveOwnerAction', abi.encode(_safe, _ownerToRemove, _decreaseThreshold)));

    // it should deploy a RemoveOwnerAction
    assertEq(address(auxRemoveOwnerAction).code, _removeOwnerAction.code);

    // it should match the parameters sent to the constructor
    assertEq(IRemoveOwnerAction(_removeOwnerAction).SAFE(), _safe);
    assertEq(IRemoveOwnerAction(_removeOwnerAction).OWNER_TO_REMOVE(), _ownerToRemove);
    assertEq(IRemoveOwnerAction(_removeOwnerAction).DECREASE_THRESHOLD(), _decreaseThreshold);
  }
}
