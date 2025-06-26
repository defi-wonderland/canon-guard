// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OnlyEntrypointGuardForTest} from './mocks/OnlyEntrypointGuardForTest.sol';
import {Enum} from '@safe-smart-account/libraries/Enum.sol';
import {Test} from 'forge-std/Test.sol';
import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';

contract UnitOnlyEntrypointGuardcheckTransaction is Test {
  OnlyEntrypointGuardForTest public onlyEntrypointGuard;

  address public immutable MULTI_SEND_CALL_ONLY = makeAddr('MULTI_SEND_CALL_ONLY');

  function setUp() public {
    onlyEntrypointGuard = new OnlyEntrypointGuardForTest();
  }

  function test_WhenCallerIsEntrypoint() external {
    // it allows transaction
    onlyEntrypointGuard.checkTransaction(
      MULTI_SEND_CALL_ONLY,
      0,
      '',
      Enum.Operation.DelegateCall,
      0,
      0,
      0,
      address(0),
      payable(address(0)),
      '',
      address(onlyEntrypointGuard) // msg.sender is entrypoint
    );
  }

  function test_WhenCallerIsNotEntrypoint(address _randomSender) external {
    vm.assume(_randomSender != address(onlyEntrypointGuard));

    // it reverts with UnauthorizedSender
    vm.expectRevert(abi.encodeWithSelector(IOnlyEntrypointGuard.UnauthorizedSender.selector, _randomSender));
    onlyEntrypointGuard.checkTransaction(
      MULTI_SEND_CALL_ONLY,
      0,
      '',
      Enum.Operation.DelegateCall,
      0,
      0,
      0,
      address(0),
      payable(address(0)),
      '',
      _randomSender
    );
  }
}
