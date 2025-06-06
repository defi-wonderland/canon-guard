// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Test} from 'forge-std/Test.sol';
import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {SimpleTransfers} from 'src/contracts/actions-builders/SimpleTransfers.sol';
import {ISimpleTransfers} from 'src/interfaces/actions-builders/ISimpleTransfers.sol';

contract UnitSimpleTransfersconstructor is Test {
  SimpleTransfers public _simpleTransfers;
  ISimpleTransfers.TransferAction[] public _transferActions;

  function setUp() external {
    _transferActions.push(ISimpleTransfers.TransferAction({token: address(0), to: address(1), amount: 100}));
    _transferActions.push(ISimpleTransfers.TransferAction({token: address(1), to: address(2), amount: 200}));
  }

  function test_WhenRun() external {
    // it should emit the events
    for (uint256 _i; _i < _transferActions.length; _i++) {
      vm.expectEmit();
      emit ISimpleTransfers.TransferActionAdded(
        _transferActions[_i].token, _transferActions[_i].to, _transferActions[_i].amount
      );
    }

    _simpleTransfers = new SimpleTransfers(_transferActions);

    // it should add the transfer to the actions array with correct values
    for (uint256 _i; _i < _transferActions.length; _i++) {
      ISimpleTransfers.TransferAction memory _transferAction = _transferActions[_i];

      // it should add the actions to the actions array with correct values
      assertEq(_simpleTransfers.getActions()[_i].target, _transferActions[_i].token);
      assertEq(
        _simpleTransfers.getActions()[_i].data,
        abi.encodeCall(IERC20.transfer, (_transferAction.to, _transferAction.amount))
      );
      assertEq(_simpleTransfers.getActions()[_i].value, 0);
    }
  }
}
