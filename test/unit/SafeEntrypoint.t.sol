// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {SafeEntrypointForTest} from './mocks/SafeEntrypointForTest.sol';
import {IOwnerManager} from '@safe-smart-account/interfaces/IOwnerManager.sol';
import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {ISafeEntrypoint} from 'contracts/SafeEntrypoint.sol';
import {ISafeManageable} from 'contracts/SafeManageable.sol';
import {Test} from 'forge-std/Test.sol';
import {IActionHub} from 'interfaces/action-hubs/IActionHub.sol';
import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';

contract UnitSafeEntrypoint is Test {
  SafeEntrypointForTest public safeEntrypoint;

  uint256 public constant SHORT_TX_EXECUTION_DELAY = 1 hours;
  uint256 public constant LONG_TX_EXECUTION_DELAY = 7 days;
  uint256 public constant DEFAULT_TX_EXPIRY_DELAY = 2 hours;
  uint256 public constant ACTIONS_BUILDER_APPROVAL_DURATION = 7 days;
  address public immutable SAFE = makeAddr('SAFE');
  address public immutable MULTI_SEND_CALL_ONLY = makeAddr('MULTI_SEND_CALL_ONLY');

  function setUp() public {
    safeEntrypoint = new SafeEntrypointForTest(
      SAFE, MULTI_SEND_CALL_ONLY, SHORT_TX_EXECUTION_DELAY, LONG_TX_EXECUTION_DELAY, DEFAULT_TX_EXPIRY_DELAY
    );
  }

  function _mockAndExpect(address _target, bytes memory _call, bytes memory _returnData) internal {
    vm.mockCall(_target, _call, _returnData);
    vm.expectCall(_target, _call);
  }

  function _mockApprovedHashesForSigners(address[] memory _signers, uint256 _approvalValue) internal {
    for (uint256 _i = 0; _i < _signers.length; _i++) {
      bytes memory _callData = abi.encodeWithSelector(ISafe.approvedHashes.selector);
      bytes memory _returnData = abi.encode(_approvalValue);
      _mockAndExpect(SAFE, _callData, _returnData);
    }
  }

  function _assumeFuzzable(address _address) internal pure {
    assumeNotForgeAddress(_address);
    assumeNotZeroAddress(_address);
    assumeNotPrecompile(_address);
  }

  function _modifyIsChildReturnValue(address _actionHub, address _actionsBuilder, bool _returnValue) internal {
    vm.mockCall(
      _actionHub, abi.encodeWithSelector(IActionHub.isChild.selector, _actionsBuilder), abi.encode(_returnValue)
    );
  }

  function test_ConstructorWhenPassingValidParameters(
    address _safe,
    address _multiSendCallOnly,
    uint256 _shortTxExecutionDelay,
    uint256 _longTxExecutionDelay,
    uint256 _defaultTxExpiryDelay
  ) external {
    safeEntrypoint = new SafeEntrypointForTest(
      _safe, _multiSendCallOnly, _shortTxExecutionDelay, _longTxExecutionDelay, _defaultTxExpiryDelay
    );
    assertEq(address(ISafeManageable(address(safeEntrypoint)).SAFE()), _safe);
    assertEq(safeEntrypoint.MULTI_SEND_CALL_ONLY(), _multiSendCallOnly);
    assertEq(safeEntrypoint.SHORT_TX_EXECUTION_DELAY(), _shortTxExecutionDelay);
    assertEq(safeEntrypoint.LONG_TX_EXECUTION_DELAY(), _longTxExecutionDelay);
    assertEq(safeEntrypoint.DEFAULT_TX_EXPIRY_DELAY(), _defaultTxExpiryDelay);
  }

  modifier whenCallerIsSafeOwner() {
    _mockAndExpect(SAFE, abi.encodeWithSelector(IOwnerManager.isOwner.selector), abi.encode(true));
    _;
  }

  function test_ApproveActionsBuilderWhenCallerIsSafe(uint256 _approvalDuration, address _actionsBuilder) external {
    _approvalDuration = bound(_approvalDuration, 0, type(uint256).max - block.timestamp);

    vm.expectEmit(address(safeEntrypoint));
    emit ISafeEntrypoint.ActionsBuilderApproved(_actionsBuilder, _approvalDuration, block.timestamp + _approvalDuration);

    vm.prank(SAFE);
    safeEntrypoint.approveActionsBuilder(_actionsBuilder, _approvalDuration);

    assertEq(safeEntrypoint.approvalExpiries(_actionsBuilder), block.timestamp + _approvalDuration);
  }

  function test_ApproveActionsBuilderWhenExtendingApproval(
    address _actionsBuilder,
    uint256 _previousApprovalExpiry,
    uint256 _newApprovalDuration
  ) external {
    _newApprovalDuration = bound(_newApprovalDuration, 0, type(uint256).max - block.timestamp);

    safeEntrypoint.mockApprovalExpiry(_actionsBuilder, _previousApprovalExpiry);

    assertEq(safeEntrypoint.approvalExpiries(_actionsBuilder), _previousApprovalExpiry);

    vm.expectEmit(address(safeEntrypoint));
    emit ISafeEntrypoint.ActionsBuilderApproved(
      _actionsBuilder, _newApprovalDuration, block.timestamp + _newApprovalDuration
    );

    vm.prank(SAFE);
    safeEntrypoint.approveActionsBuilder(_actionsBuilder, _newApprovalDuration);

    assertEq(safeEntrypoint.approvalExpiries(_actionsBuilder), block.timestamp + _newApprovalDuration);
  }

  function test_ApproveActionsBuilderWhenCallerIsNotSafe(
    address _caller,
    uint256 _approvalDuration,
    address _actionsBuilder
  ) external {
    vm.assume(_caller != SAFE);
    vm.expectRevert(ISafeManageable.NotSafe.selector);
    vm.prank(_caller);
    safeEntrypoint.approveActionsBuilder(_actionsBuilder, _approvalDuration);
  }

  function test_QueueTransactionWhenQueueingPreApprovedAction(
    address _caller,
    address _actionsBuilder,
    uint256 _expiryDelay
  ) external whenCallerIsSafeOwner givenActionsBuilderIsApproved(_actionsBuilder) {
    _assumeFuzzable(_actionsBuilder);
    _expiryDelay = bound(_expiryDelay, 1, type(uint256).max - block.timestamp - SHORT_TX_EXECUTION_DELAY);

    _mockAndExpect(
      address(_actionsBuilder),
      abi.encodeWithSelector(IActionsBuilder.getActions.selector),
      abi.encode(new IActionsBuilder.Action[](0))
    );

    // it emits TransactionQueued event
    vm.expectEmit(address(safeEntrypoint));
    emit ISafeEntrypoint.TransactionQueued(address(0), _actionsBuilder);

    vm.prank(_caller);
    safeEntrypoint.queueTransaction(_actionsBuilder, _expiryDelay);

    // Verify transaction info using the new interface
    (bytes memory _actionsData, uint256 _executableAt, uint256 _expiresAt, bool _isExecuted) =
      safeEntrypoint.queuedTransactions(_actionsBuilder);

    // it sets transaction info
    assertEq(_actionsData, abi.encode(new IActionsBuilder.Action[](0)));
    assertEq(_isExecuted, false);
    // it sets executable at to block timestamp plus short delay
    assertEq(_executableAt, block.timestamp + SHORT_TX_EXECUTION_DELAY);
    // it sets expiry time
    assertEq(_expiresAt, block.timestamp + SHORT_TX_EXECUTION_DELAY + _expiryDelay);
  }

  function test_QueueTransactionWhenQueueingArbitraryAction(
    address _caller,
    address _target,
    uint256 _value,
    address _actionsBuilder,
    bytes memory _data,
    uint256 _expiryDelay
  ) external whenCallerIsSafeOwner {
    _assumeFuzzable(_actionsBuilder);
    _expiryDelay = bound(_expiryDelay, 1, type(uint256).max - block.timestamp - LONG_TX_EXECUTION_DELAY);

    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = IActionsBuilder.Action({target: _target, value: _value, data: _data});

    _mockAndExpect(
      address(_actionsBuilder), abi.encodeWithSelector(IActionsBuilder.getActions.selector), abi.encode(_actions)
    );

    // it emits TransactionQueued event
    vm.expectEmit(address(safeEntrypoint));
    emit ISafeEntrypoint.TransactionQueued(address(0), _actionsBuilder);

    vm.prank(_caller);
    safeEntrypoint.queueTransaction(_actionsBuilder, _expiryDelay);

    // Verify transaction info using the new interface
    (bytes memory _actionsData, uint256 _executableAt, uint256 _expiresAt, bool _isExecuted) =
      safeEntrypoint.queuedTransactions(_actionsBuilder);

    // it sets transaction info
    assertEq(_actionsData, abi.encode(_actions));
    assertEq(_isExecuted, false);
    // it sets executable at to block timestamp plus long delay
    assertEq(_executableAt, block.timestamp + LONG_TX_EXECUTION_DELAY);
    // it sets expiry time
    assertEq(_expiresAt, block.timestamp + LONG_TX_EXECUTION_DELAY + _expiryDelay);
  }

  function test_QueueTransactionWhenCallerIsNotSafeOwner(
    address _caller,
    address _actionsBuilder,
    uint256 _expiryDelay
  ) external givenCallerIsNotSafeOwner(_caller) {
    _expiryDelay = bound(_expiryDelay, 0, type(uint256).max - block.timestamp - SHORT_TX_EXECUTION_DELAY);

    // it reverts with NotSafeOwner
    vm.expectRevert(ISafeManageable.NotSafeOwner.selector);
    vm.prank(_caller);
    safeEntrypoint.queueTransaction(_actionsBuilder, _expiryDelay);
  }

  function test_QueueHubTransactionWhenHubIsNotAChild(
    address _actionHub,
    address _actionsBuilder,
    uint256 _expiryDelay
  ) external whenCallerIsSafeOwner {
    _assumeFuzzable(_actionHub);
    _assumeFuzzable(_actionsBuilder);
    _modifyIsChildReturnValue(_actionHub, _actionsBuilder, false);

    // it reverts with InvalidHubOrActionsBuilder
    vm.expectRevert(ISafeEntrypoint.InvalidHubOrActionsBuilder.selector);
    safeEntrypoint.queueHubTransaction(_actionHub, _actionsBuilder, _expiryDelay);
  }

  function test_QueueHubTransactionWhenQueueingPreApprovedAction(
    address _caller,
    address _actionHub,
    address _actionsBuilder,
    uint256 _expiryDelay
  ) external whenCallerIsSafeOwner givenActionsBuilderIsApproved(_actionHub) {
    _assumeFuzzable(_actionHub);
    _assumeFuzzable(_actionsBuilder);
    _modifyIsChildReturnValue(_actionHub, _actionsBuilder, true);
    _expiryDelay = bound(_expiryDelay, 1, type(uint256).max - block.timestamp - SHORT_TX_EXECUTION_DELAY);

    _mockAndExpect(
      address(_actionsBuilder),
      abi.encodeWithSelector(IActionsBuilder.getActions.selector),
      abi.encode(new IActionsBuilder.Action[](0))
    );

    // it emits TransactionQueued event
    vm.expectEmit(address(safeEntrypoint));
    emit ISafeEntrypoint.TransactionQueued(_actionHub, _actionsBuilder);

    vm.prank(_caller);
    safeEntrypoint.queueHubTransaction(_actionHub, _actionsBuilder, _expiryDelay);

    // Verify transaction info using the new interface
    (bytes memory _actionsData, uint256 _executableAt, uint256 _expiresAt, bool _isExecuted) =
      safeEntrypoint.queuedTransactions(_actionsBuilder);

    // it sets transaction info
    assertEq(_actionsData, abi.encode(new IActionsBuilder.Action[](0)));
    assertEq(_isExecuted, false);
    // it sets executable at to block timestamp plus short delay
    assertEq(_executableAt, block.timestamp + SHORT_TX_EXECUTION_DELAY);
    // it sets expiry time
    assertEq(_expiresAt, block.timestamp + SHORT_TX_EXECUTION_DELAY + _expiryDelay);
  }

  function test_QueueHubTransactionWhenQueueingArbitraryAction(
    address _caller,
    address _target,
    uint256 _value,
    address _actionHub,
    address _actionsBuilder,
    bytes memory _data,
    uint256 _expiryDelay
  ) external whenCallerIsSafeOwner {
    _modifyIsChildReturnValue(_actionHub, _actionsBuilder, true);
    _assumeFuzzable(_actionHub);
    _assumeFuzzable(_actionsBuilder);
    _expiryDelay = bound(_expiryDelay, 1, type(uint256).max - block.timestamp - LONG_TX_EXECUTION_DELAY);

    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = IActionsBuilder.Action({target: _target, value: _value, data: _data});

    _mockAndExpect(
      address(_actionsBuilder), abi.encodeWithSelector(IActionsBuilder.getActions.selector), abi.encode(_actions)
    );

    // it emits TransactionQueued event
    vm.expectEmit(address(safeEntrypoint));
    emit ISafeEntrypoint.TransactionQueued(_actionHub, _actionsBuilder);

    vm.prank(_caller);
    safeEntrypoint.queueHubTransaction(_actionHub, _actionsBuilder, _expiryDelay);

    // Verify transaction info using the new interface
    (bytes memory _actionsData, uint256 _executableAt, uint256 _expiresAt, bool _isExecuted) =
      safeEntrypoint.queuedTransactions(_actionsBuilder);

    // it sets transaction info
    assertEq(_actionsData, abi.encode(_actions));
    assertEq(_isExecuted, false);
    // it sets executable at to block timestamp plus long delay
    assertEq(_executableAt, block.timestamp + LONG_TX_EXECUTION_DELAY);
    // it sets expiry time
    assertEq(_expiresAt, block.timestamp + LONG_TX_EXECUTION_DELAY + _expiryDelay);
  }

  function test_QueueHubTransactionWhenCallerIsNotSafeOwner(
    address _caller,
    address _actionHub,
    address _actionsBuilder,
    uint256 _expiryDelay
  ) external givenCallerIsNotSafeOwner(_caller) {
    _assumeFuzzable(_caller);
    _assumeFuzzable(_actionHub);
    _assumeFuzzable(_actionsBuilder);
    _modifyIsChildReturnValue(_actionHub, _actionsBuilder, true);

    _expiryDelay = bound(_expiryDelay, 0, type(uint256).max - block.timestamp - SHORT_TX_EXECUTION_DELAY);

    // it reverts with NotSafeOwner
    vm.expectRevert(ISafeManageable.NotSafeOwner.selector);
    vm.prank(_caller);
    safeEntrypoint.queueHubTransaction(_actionHub, _actionsBuilder, _expiryDelay);
  }

  function test_ExecuteTransactionWhenTransactionIsExpired(
    address _caller,
    address _actionsBuilder,
    IActionsBuilder.Action calldata _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo
  ) external {
    vm.assume(_txInfo.expiresAt < type(uint64).max - 1);
    _txInfo.executableAt = bound(_txInfo.executableAt, 0, block.timestamp);
    _txInfo.isExecuted = false;
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);
    safeEntrypoint.mockTransaction(
      _actionsBuilder, _actionsData, _txInfo.executableAt, _txInfo.expiresAt, _txInfo.isExecuted
    );

    // Move time forward past expiry
    vm.warp(_txInfo.expiresAt + 1);

    vm.expectRevert(ISafeEntrypoint.TransactionExpired.selector);
    vm.prank(_caller);
    safeEntrypoint.executeTransaction(_actionsBuilder);
  }

  function test_ExecuteTransactionWhenApprovedTransactionIsAlreadyExecuted(
    address _caller,
    address _actionsBuilder,
    IActionsBuilder.Action calldata _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo
  ) external {
    _txInfo.expiresAt = bound(_txInfo.expiresAt, block.timestamp + 1, type(uint256).max);
    _txInfo.executableAt = bound(_txInfo.executableAt, block.timestamp + 1, type(uint256).max);
    _txInfo.isExecuted = true;
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);

    // Mock an already executed transaction
    safeEntrypoint.mockTransaction(
      _actionsBuilder, // actionsBuilder
      _actionsData, // actionsData
      _txInfo.executableAt, // executableAt
      _txInfo.expiresAt, // expiresAt
      _txInfo.isExecuted // isExecuted
    );

    vm.expectRevert(ISafeEntrypoint.TransactionAlreadyExecuted.selector);
    vm.prank(_caller);
    safeEntrypoint.executeTransaction(_actionsBuilder);
  }

  function test_ExecuteTransactionWhenApprovedTransactionIsNotYetExecutable(
    address _caller,
    address _actionsBuilder,
    IActionsBuilder.Action calldata _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo
  ) external {
    _txInfo.expiresAt = bound(_txInfo.expiresAt, block.timestamp + 1, type(uint256).max);
    _txInfo.executableAt = bound(_txInfo.executableAt, block.timestamp + 1, type(uint256).max);
    _txInfo.isExecuted = false;
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);

    // Mock a transaction that is not yet executable
    safeEntrypoint.mockTransaction(
      _actionsBuilder, // actionsBuilder
      _actionsData, // actionsData
      _txInfo.executableAt, // executableAt
      _txInfo.expiresAt, // expiresAt
      _txInfo.isExecuted // isExecuted
    );

    vm.expectRevert(ISafeEntrypoint.TransactionNotYetExecutable.selector);
    vm.prank(_caller);
    safeEntrypoint.executeTransaction(_actionsBuilder);
  }

  function test_ExecuteTransactionWhenApprovedTransactionIsValid(
    address _caller,
    address _actionsBuilder,
    IActionsBuilder.Action calldata _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo
  ) external {
    _txInfo.expiresAt = bound(_txInfo.expiresAt, block.timestamp + 1, type(uint256).max);
    _txInfo.executableAt = bound(_txInfo.executableAt, block.timestamp - 1, block.timestamp);
    _txInfo.isExecuted = false;
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);

    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.nonce.selector), abi.encode(1));
    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.getTransactionHash.selector), abi.encode(bytes32(0)));
    _mockAndExpect(SAFE, abi.encodeWithSelector(IOwnerManager.getOwners.selector), abi.encode(new address[](0)));
    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.execTransaction.selector), abi.encode(true));

    safeEntrypoint.mockTransaction(
      _actionsBuilder, // actionsBuilder
      _actionsData, // actionsData
      _txInfo.executableAt, // executableAt
      _txInfo.expiresAt, // expiresAt
      _txInfo.isExecuted // isExecuted
    );

    bool _isArbitrary = _actionsBuilder == address(0);

    vm.expectEmit(address(safeEntrypoint));
    emit ISafeEntrypoint.TransactionExecuted(_actionsBuilder, _isArbitrary, bytes32(0), new address[](0));

    vm.prank(_caller);
    safeEntrypoint.executeTransaction(_actionsBuilder);

    // Note: After execution, the transaction is cleared from the queue, so queuedTransaction returns empty values
    // The execution should be verified through the emitted event instead
  }

  modifier whenTransactionExists() {
    _;
  }

  function test_GetSafeTransactionHashWhenTransactionExists(
    address _actionsBuilder,
    IActionsBuilder.Action memory _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo,
    uint256 _safeNonce,
    bytes32 _expectedHash
  ) external {
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);
    safeEntrypoint.mockTransaction(
      _actionsBuilder, _actionsData, _txInfo.executableAt, _txInfo.expiresAt, _txInfo.isExecuted
    );

    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.nonce.selector), abi.encode(_safeNonce));
    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.getTransactionHash.selector), abi.encode(_expectedHash));

    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(_actionsBuilder);
    assertEq(_safeTxHash, _expectedHash);
  }

  function test_GetSafeTransactionHashWhenGettingHashWithNonce(
    address _actionsBuilder,
    IActionsBuilder.Action memory _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo,
    uint256 _safeNonce,
    bytes32 _expectedHash
  ) external {
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);
    safeEntrypoint.mockTransaction(
      _actionsBuilder, _actionsData, _txInfo.executableAt, _txInfo.expiresAt, _txInfo.isExecuted
    );

    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.getTransactionHash.selector), abi.encode(_expectedHash));

    bytes32 _safeTxHash = safeEntrypoint.getSafeTransactionHash(_actionsBuilder, _safeNonce);
    assertEq(_safeTxHash, _expectedHash);
  }

  function test_GetApprovedHashSignersWhenGettingSignersWithActionsBuilder(
    address _actionsBuilder,
    IActionsBuilder.Action memory _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo,
    address _signer1,
    address _signer2
  ) external {
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);
    safeEntrypoint.mockTransaction(
      _actionsBuilder, _actionsData, _txInfo.executableAt, _txInfo.expiresAt, _txInfo.isExecuted
    );

    address[] memory _signers = new address[](2);
    _signers[0] = _signer1;
    _signers[1] = _signer2;
    _mockApprovedHashesForSigners(_signers, 1);

    _mockAndExpect(SAFE, abi.encodeWithSelector(IOwnerManager.getOwners.selector), abi.encode(_signers));
    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.nonce.selector), abi.encode(1));
    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.getTransactionHash.selector), abi.encode(bytes32(0)));

    address[] memory _approvedSigners = safeEntrypoint.getApprovedHashSigners(_actionsBuilder);
    assertEq(_approvedSigners, _signers);
  }

  function test_GetApprovedHashSignersWhenGettingSignersWithActionsBuilderAndNonce(
    address _signer1,
    address _signer2,
    address _actionsBuilder,
    IActionsBuilder.Action memory _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo,
    uint256 _safeNonce
  ) external {
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);
    safeEntrypoint.mockTransaction(
      _actionsBuilder, _actionsData, _txInfo.executableAt, _txInfo.expiresAt, _txInfo.isExecuted
    );

    address[] memory _signers = new address[](2);
    _signers[0] = _signer1;
    _signers[1] = _signer2;
    _mockApprovedHashesForSigners(_signers, 1);

    _mockAndExpect(SAFE, abi.encodeWithSelector(IOwnerManager.getOwners.selector), abi.encode(_signers));
    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.getTransactionHash.selector), abi.encode(bytes32(0)));

    address[] memory _approvedSigners = safeEntrypoint.getApprovedHashSigners(_actionsBuilder, _safeNonce);
    assertEq(_approvedSigners, _signers);
  }

  function test_GetApprovedHashSignersWhenGettingSignersWithHash(
    address _signer1,
    address _signer2,
    bytes32 _safeHash
  ) external {
    address[] memory _signers = new address[](2);
    _signers[0] = _signer1;
    _signers[1] = _signer2;
    _mockApprovedHashesForSigners(_signers, 1);

    _mockAndExpect(SAFE, abi.encodeWithSelector(IOwnerManager.getOwners.selector), abi.encode(_signers));

    address[] memory _approvedSigners = safeEntrypoint.getApprovedHashSigners(_safeHash);
    assertEq(_approvedSigners, _signers);
  }

  modifier givenCallerIsSafeOwner(address _caller) {
    _mockAndExpect(SAFE, abi.encodeWithSelector(IOwnerManager.isOwner.selector), abi.encode(true));
    _;
  }

  modifier givenCallerIsNotSafeOwner(address _caller) {
    _mockAndExpect(SAFE, abi.encodeWithSelector(IOwnerManager.isOwner.selector), abi.encode(false));
    _;
  }

  modifier givenActionsBuilderIsApproved(address _actionsBuilder) {
    vm.prank(SAFE);
    safeEntrypoint.approveActionsBuilder(_actionsBuilder, ACTIONS_BUILDER_APPROVAL_DURATION);
    _;
  }

  function test_ExecuteTransaction(
    address _caller,
    address _actionsBuilder,
    IActionsBuilder.Action calldata _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo
  ) external {
    _txInfo.expiresAt = bound(_txInfo.expiresAt, block.timestamp + 1, type(uint256).max);
    _txInfo.executableAt = bound(_txInfo.executableAt, block.timestamp - 1, block.timestamp);
    _txInfo.isExecuted = false;
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);

    // Mock an already executed transaction
    safeEntrypoint.mockTransaction(
      _actionsBuilder, // actionsBuilder
      _actionsData, // actionsData
      _txInfo.executableAt, // executableAt
      _txInfo.expiresAt, // expiresAt
      true // isExecuted
    );

    vm.expectRevert(ISafeEntrypoint.TransactionAlreadyExecuted.selector);
    vm.prank(_caller);
    safeEntrypoint.executeTransaction(_actionsBuilder);
  }

  function test_GetApprovedHashSignersWhenTransactionExists(
    address _actionsBuilder,
    IActionsBuilder.Action memory _action,
    ISafeEntrypoint.TransactionInfo memory _txInfo,
    address _signer1,
    address _signer2
  ) external {
    IActionsBuilder.Action[] memory _actions = new IActionsBuilder.Action[](1);
    _actions[0] = _action;
    bytes memory _actionsData = abi.encode(_actions);
    safeEntrypoint.mockTransaction(
      _actionsBuilder, _actionsData, _txInfo.executableAt, _txInfo.expiresAt, _txInfo.isExecuted
    );

    address[] memory _signers = new address[](2);
    _signers[0] = _signer1;
    _signers[1] = _signer2;
    _mockApprovedHashesForSigners(_signers, 1);

    _mockAndExpect(SAFE, abi.encodeWithSelector(IOwnerManager.getOwners.selector), abi.encode(_signers));
    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.nonce.selector), abi.encode(1));
    _mockAndExpect(SAFE, abi.encodeWithSelector(ISafe.getTransactionHash.selector), abi.encode(bytes32(0)));

    address[] memory _approvedSigners = safeEntrypoint.getApprovedHashSigners(_actionsBuilder);
    assertEq(_approvedSigners, _signers);
  }
}
