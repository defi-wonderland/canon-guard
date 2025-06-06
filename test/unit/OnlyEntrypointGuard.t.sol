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

  address internal _sender;
  bytes internal _validSignature;
  bytes internal _invalidSignature;

  function setUp() public {
    onlyEntrypointGuard = new OnlyEntrypointGuardForTest(ENTRYPOINT, EMERGENCY_CALLER, MULTI_SEND_CALL_ONLY);

    _validSignature = new bytes(65);
    _validSignature[64] = bytes1(uint8(1));

    _invalidSignature = new bytes(65);
  }

  function _assumeFuzzable(address _address) internal pure {
    assumeNotForgeAddress(_address);
    assumeNotZeroAddress(_address);
    assumeNotPrecompile(_address);
  }

  /// @dev Concatenates 3 signatures
  function concatSigs(bytes memory sig1, bytes memory sig2, bytes memory sig3) public pure returns (bytes memory) {
    bytes memory b = new bytes(sig1.length + sig2.length + sig3.length);
    uint256 k = 0;
    for (uint256 i = 0; i < sig1.length; i++) {
      b[k++] = sig1[i];
    }
    for (uint256 i = 0; i < sig2.length; i++) {
      b[k++] = sig2[i];
    }
    for (uint256 i = 0; i < sig3.length; i++) {
      b[k++] = sig3[i];
    }
    return b;
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

  modifier whenCallerIsEntrypointOrEmergencyCaller(uint256 _seed) {
    // if seed is even, caller is entrypoint, otherwise emergency caller
    if (_seed % 2 == 0) {
      _sender = ENTRYPOINT;
    } else {
      _sender = EMERGENCY_CALLER;
    }
    _;
  }

  modifier whenOperationIsDelegateCall() {
    _;
  }

  function test_CheckTransactionWhenTargetIsMultiSendCallOnly(uint256 _seed)
    external
    whenCallerIsEntrypointOrEmergencyCaller(_seed)
    whenOperationIsDelegateCall
  {
    // it allows transaction
    onlyEntrypointGuard.checkTransaction(
      MULTI_SEND_CALL_ONLY, 0, '', Enum.Operation.DelegateCall, 0, 0, 0, address(0), payable(address(0)), '', _sender
    );
  }

  function test_CheckTransactionWhenTargetIsNotMultiSendCallOnly(
    uint256 _seed,
    address _target
  ) external whenCallerIsEntrypointOrEmergencyCaller(_seed) whenOperationIsDelegateCall {
    vm.assume(_target != MULTI_SEND_CALL_ONLY);

    // it reverts with UnauthorizedDelegateCall
    vm.expectRevert(abi.encodeWithSelector(IOnlyEntrypointGuard.UnauthorizedDelegateCall.selector, _target));
    onlyEntrypointGuard.checkTransaction(
      _target, 0, '', Enum.Operation.DelegateCall, 0, 0, 0, address(0), payable(address(0)), '', _sender
    );
  }

  function test_CheckTransactionWhenSignatureIsNotApprovedHashSignature() external {
    // it reverts with InvalidSignatureType
    vm.expectRevert(IOnlyEntrypointGuard.InvalidSignatureType.selector);
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
      _invalidSignature,
      ENTRYPOINT
    );
  }

  function test_CheckTransactionWhenCallerIsNotEntrypointOrEmergencyCaller(address _randomSender) external {
    vm.assume(_randomSender != ENTRYPOINT);
    vm.assume(_randomSender != EMERGENCY_CALLER);

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

  function test__isValidSignatureTypeWhenAtLeastOneOfTheSignaturesIsNotAnApprovedHashSignature() external {
    // add up 2 valid and 1 invalid signature
    bytes memory _signatures = concatSigs(_validSignature, _validSignature, _invalidSignature);

    // it returns false
    assertFalse(onlyEntrypointGuard.isValidSignatureType(_signatures));
  }

  function test__isValidSignatureTypeWhenAllSignaturesAreApprovedHashSignatures() external {
    // add up 3 valid signatures
    bytes memory _signatures = concatSigs(_validSignature, _validSignature, _validSignature);

    // it returns true
    assertTrue(onlyEntrypointGuard.isValidSignatureType(_signatures));
  }
}
