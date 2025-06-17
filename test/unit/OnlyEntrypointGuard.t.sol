// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OnlyEntrypointGuardForTest} from './mocks/OnlyEntrypointGuardForTest.sol';
import {Enum} from '@safe-smart-account/libraries/Enum.sol';
import {Test} from 'forge-std/Test.sol';
import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';
import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';

contract UnitOnlyEntrypointGuard is Test {
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

  modifier whenCallerIsEntrypoint(uint256 _seed) {
    _sender = address(onlyEntrypointGuard);
    _;
  }

  function test_CheckTransactionWhenCallerIsNotEntrypoint(address _randomSender) external {
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
