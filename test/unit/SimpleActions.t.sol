// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Test} from 'forge-std/Test.sol';
import {SimpleActions} from 'src/contracts/actions-builders/SimpleActions.sol';
import {ISimpleActions} from 'src/interfaces/actions-builders/ISimpleActions.sol';

contract UnitSimpleActionsconstructor is Test {
  SimpleActions public simpleActions;
  ISimpleActions.SimpleAction[] public actions;

  function setUp() public {
    actions.push(
      ISimpleActions.SimpleAction({
        target: address(1),
        signature: 'transfer(address,uint256)',
        data: abi.encode(address(0), 100),
        value: 0
      })
    );

    actions.push(
      ISimpleActions.SimpleAction({
        target: address(2),
        signature: 'approve(address,uint256)',
        data: abi.encode(address(0), 100),
        value: 0
      })
    );
  }

  function test_WhenRun() external {
    // it should emit the events
    for (uint256 _i; _i < actions.length; _i++) {
      vm.expectEmit();
      emit ISimpleActions.SimpleActionAdded(
        actions[_i].target, actions[_i].signature, actions[_i].data, actions[_i].value
      );
    }

    simpleActions = new SimpleActions(actions);

    for (uint256 _i; _i < actions.length; _i++) {
      ISimpleActions.SimpleAction memory _simpleAction = actions[_i];

      bytes4 _selector = bytes4(keccak256(bytes(_simpleAction.signature)));
      bytes memory _completeCallData = abi.encodePacked(_selector, _simpleAction.data);

      // it should add the actions to the actions array with correct values
      assertEq(simpleActions.getActions()[_i].target, _simpleAction.target);
      assertEq(simpleActions.getActions()[_i].data, _completeCallData);
      assertEq(simpleActions.getActions()[_i].value, actions[_i].value);
    }
  }
}
