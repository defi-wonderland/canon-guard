// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OnlyEntrypointGuardForTest} from './mocks/OnlyEntrypointGuardForTest.sol';
import {Enum} from '@safe-smart-account/libraries/Enum.sol';
import {Test} from 'forge-std/Test.sol';
import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';

contract UnitOnlyEntrypointGuard is Test {
  OnlyEntrypointGuardForTest public onlyEntrypointGuard;
  address public immutable ENTRYPOINT = makeAddr('ENTRYPOINT');
  address public immutable EMERGENCY_CALLER = makeAddr('EMERGENCY_CALLER');
  address public immutable MULTI_SEND_CALL_ONLY = makeAddr('MULTI_SEND_CALL_ONLY');

  function setUp() public {
    onlyEntrypointGuard = new OnlyEntrypointGuardForTest(ENTRYPOINT, EMERGENCY_CALLER, MULTI_SEND_CALL_ONLY);
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
    vm.prank(ENTRYPOINT);
    _;
  }

  function test_CheckTransactionWhenOperationIsEntrypointCall() external whenCallerIsEntrypoint {
    onlyEntrypointGuard.checkTransaction(
      address(0), 0, '', Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), '', ENTRYPOINT
    );
  }

  modifier whenOperationIsEntrypointDelegateCall() {
    _;
  }

  function test_CheckTransactionWhenTargetIsEntrypointMultiSendCallOnly()
    external
    whenCallerIsEntrypoint
    whenOperationIsEntrypointDelegateCall
  {
    onlyEntrypointGuard.checkTransaction(
      MULTI_SEND_CALL_ONLY, 0, '', Enum.Operation.DelegateCall, 0, 0, 0, address(0), payable(address(0)), '', ENTRYPOINT
    );
  }

  function test_CheckTransactionWhenTargetIsNotEntrypointMultiSendCallOnly()
    external
    whenCallerIsEntrypoint
    whenOperationIsEntrypointDelegateCall
  {
    vm.expectRevert(abi.encodeWithSelector(IOnlyEntrypointGuard.UnauthorizedDelegateCall.selector, address(0)));
    onlyEntrypointGuard.checkTransaction(
      address(0), 0, '', Enum.Operation.DelegateCall, 0, 0, 0, address(0), payable(address(0)), '', ENTRYPOINT
    );
  }

  modifier whenCallerIsEmergencyCaller() {
    vm.prank(EMERGENCY_CALLER);
    _;
  }

  function test_CheckTransactionWhenOperationIsEmergencyCall() external whenCallerIsEmergencyCaller {
    onlyEntrypointGuard.checkTransaction(
      address(0), 0, '', Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), '', EMERGENCY_CALLER
    );
  }

  modifier whenOperationIsEmergencyDelegateCall() {
    _;
  }

  function test_CheckTransactionWhenTargetIsEmergencyMultiSendCallOnly()
    external
    whenCallerIsEmergencyCaller
    whenOperationIsEmergencyDelegateCall
  {
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
      EMERGENCY_CALLER
    );
  }

  function test_CheckTransactionWhenTargetIsNotEmergencyMultiSendCallOnly()
    external
    whenCallerIsEmergencyCaller
    whenOperationIsEmergencyDelegateCall
  {
    vm.expectRevert(abi.encodeWithSelector(IOnlyEntrypointGuard.UnauthorizedDelegateCall.selector, address(0)));
    onlyEntrypointGuard.checkTransaction(
      address(0), 0, '', Enum.Operation.DelegateCall, 0, 0, 0, address(0), payable(address(0)), '', EMERGENCY_CALLER
    );
  }

  function test_CheckTransactionWhenCallerIsNotEntrypointOrEmergencyCaller() external {
    vm.prank(address(0));
    vm.expectRevert(abi.encodeWithSelector(IOnlyEntrypointGuard.UnauthorizedSender.selector, address(0)));
    onlyEntrypointGuard.checkTransaction(
      address(0), 0, '', Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), '', address(0)
    );
  }

  function _assumeFuzzable(address _address) internal pure {
    assumeNotForgeAddress(_address);
    assumeNotZeroAddress(_address);
    assumeNotPrecompile(_address);
  }
}
