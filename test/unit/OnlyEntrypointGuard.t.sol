// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OnlyEntrypointGuardForTest} from './mocks/OnlyEntrypointGuardForTest.sol';
import {Enum} from '@safe-smart-account/libraries/Enum.sol';
import {Test} from 'forge-std/Test.sol';
import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';
import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';

contract UnitOnlyEntrypointGuardcheckTransaction is Test {
  function test_WhenCallerIsEntrypoint() external {
    // it allows transaction
  }

  function test_WhenCallerIsNotEntrypoint() external {
    // it reverts with UnauthorizedSender
  }

  OnlyEntrypointGuardForTest public onlyEntrypointGuard;

  address public immutable MULTI_SEND_CALL_ONLY = makeAddr('MULTI_SEND_CALL_ONLY');

  address internal _sender;
  bytes internal _validSignature;
  bytes internal _invalidSignature;

  function setUp() public {
    onlyEntrypointGuard = new OnlyEntrypointGuardForTest();
  }

  function _mockAndExpect(address _target, bytes memory _call, bytes memory _returnData) internal {
    vm.mockCall(_target, _call, _returnData);
    vm.expectCall(_target, _call);
  }

  function _assumeFuzzable(address _address) internal pure {
    assumeNotForgeAddress(_address);
    assumeNotZeroAddress(_address);
    assumeNotPrecompile(_address);
  }

  function test_WhenCallerIsEntrypoint() external {
    // it allows transaction
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
      onlyEntrypointGuard // msg.sender is entrypoint
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
