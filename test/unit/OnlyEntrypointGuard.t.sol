// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OnlyEntrypointGuardForTest} from './mocks/OnlyEntrypointGuardForTest.sol';

import {Enum} from '@safe-smart-account/libraries/Enum.sol';
import {Test} from 'forge-std/Test.sol';
import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';

contract UnitOnlyEntrypointGuard is Test {
  OnlyEntrypointGuardForTest onlyEntrypointGuard;
  address public immutable ENTRYPOINT = makeAddr('ENTRYPOINT');
  address public immutable EMERGENCY_CALLER = makeAddr('EMERGENCY_CALLER');
  address public immutable MULTI_SEND_CALL_ONLY = makeAddr('MULTI_SEND_CALL_ONLY');

  function setUp() public {
    onlyEntrypointGuard = new OnlyEntrypointGuardForTest(ENTRYPOINT, EMERGENCY_CALLER, MULTI_SEND_CALL_ONLY);
  }

  function _assumeFuzzable(address _address) internal pure {
    assumeNotForgeAddress(_address);
    assumeNotZeroAddress(_address);
    assumeNotPrecompile(_address);
  }

  function test_ConstructorWhenPassingValidParameters(
    address _entrypoint,
    address _emergencyCaller,
    address _multiSendCallOnly
  ) external {
    _assumeFuzzable(_entrypoint);
    _assumeFuzzable(_emergencyCaller);
    _assumeFuzzable(_multiSendCallOnly);

    OnlyEntrypointGuardForTest newOnlyEntrypointGuard =
      new OnlyEntrypointGuardForTest(_entrypoint, _emergencyCaller, _multiSendCallOnly);

    assertEq(newOnlyEntrypointGuard.ENTRYPOINT(), _entrypoint);
    assertEq(newOnlyEntrypointGuard.EMERGENCY_CALLER(), _emergencyCaller);
    assertEq(newOnlyEntrypointGuard.MULTI_SEND_CALL_ONLY(), _multiSendCallOnly);
  }

  modifier whenCallerIsEntrypoint() {
    _;
  }

  function test_CheckTransactionWhenCallerIsEntrypointWhenOperationIsCall() external whenCallerIsEntrypoint {
    onlyEntrypointGuard.checkTransaction(
      address(0), 0, bytes(''), Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), bytes(''), ENTRYPOINT
    );
  }

  function test_CheckTransactionWhenCallerIsEntrypointWhenOperationIsDelegateCallWhenTargetIsMultiSendCallOnly()
    external
    whenCallerIsEntrypoint
  {
    onlyEntrypointGuard.checkTransaction(
      MULTI_SEND_CALL_ONLY,
      0,
      bytes(''),
      Enum.Operation.DelegateCall,
      0,
      0,
      0,
      address(0),
      payable(address(0)),
      bytes(''),
      ENTRYPOINT
    );
  }

  function test_CheckTransactionWhenCallerIsEntrypointWhenOperationIsDelegateCallWhenTargetIsNotMultiSendCallOnly(
    address _target
  ) external whenCallerIsEntrypoint {
    vm.assume(_target != MULTI_SEND_CALL_ONLY);
    vm.expectRevert(abi.encodeWithSelector(IOnlyEntrypointGuard.UnauthorizedDelegateCall.selector, _target));
    onlyEntrypointGuard.checkTransaction(
      _target,
      0,
      bytes(''),
      Enum.Operation.DelegateCall,
      0,
      0,
      0,
      address(0),
      payable(address(0)),
      bytes(''),
      ENTRYPOINT
    );
  }

  modifier whenCallerIsEmergencyCaller() {
    _;
  }

  function test_CheckTransactionWhenCallerIsEmergencyCallerWhenOperationIsCall() external whenCallerIsEmergencyCaller {
    onlyEntrypointGuard.checkTransaction(
      address(0),
      0,
      bytes(''),
      Enum.Operation.Call,
      0,
      0,
      0,
      address(0),
      payable(address(0)),
      bytes(''),
      EMERGENCY_CALLER
    );
  }

  function test_CheckTransactionWhenCallerIsEmergencyCallerWhenOperationIsDelegateCallWhenTargetIsMultiSendCallOnly()
    external
    whenCallerIsEmergencyCaller
  {
    onlyEntrypointGuard.checkTransaction(
      MULTI_SEND_CALL_ONLY,
      0,
      bytes(''),
      Enum.Operation.DelegateCall,
      0,
      0,
      0,
      address(0),
      payable(address(0)),
      bytes(''),
      EMERGENCY_CALLER
    );
  }

  function test_CheckTransactionWhenCallerIsEmergencyCallerWhenOperationIsDelegateCallWhenTargetIsNotMultiSendCallOnly(
    address _target
  ) external whenCallerIsEmergencyCaller {
    vm.assume(_target != MULTI_SEND_CALL_ONLY);
    vm.expectRevert(abi.encodeWithSelector(IOnlyEntrypointGuard.UnauthorizedDelegateCall.selector, _target));
    onlyEntrypointGuard.checkTransaction(
      _target,
      0,
      bytes(''),
      Enum.Operation.DelegateCall,
      0,
      0,
      0,
      address(0),
      payable(address(0)),
      bytes(''),
      EMERGENCY_CALLER
    );
  }

  function test_CheckTransactionWhenCallerIsNotEntrypointOrEmergencyCaller(address _caller) external {
    vm.assume(_caller != ENTRYPOINT && _caller != EMERGENCY_CALLER);
    vm.expectRevert(abi.encodeWithSelector(IOnlyEntrypointGuard.UnauthorizedSender.selector, _caller));
    onlyEntrypointGuard.checkTransaction(
      address(0), 0, bytes(''), Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), bytes(''), _caller
    );
  }
}
