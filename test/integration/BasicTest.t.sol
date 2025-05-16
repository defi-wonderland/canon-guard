// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Test} from 'forge-std/Test.sol';

import {SafeEntrypoint} from 'contracts/SafeEntrypoint.sol';
import {SafeEntrypointFactory} from 'contracts/factories/SafeEntrypointFactory.sol';
import {SimpleActionsFactory} from 'contracts/factories/SimpleActionsFactory.sol';

import {ISimpleActions} from 'interfaces/actions/ISimpleActions.sol';

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {SafeProxyFactory} from '@safe-smart-account/proxies/SafeProxyFactory.sol';

import {
  DEFAULT_TX_EXPIRY_DELAY,
  LONG_TX_EXECUTION_DELAY,
  MULTI_SEND_CALL_ONLY,
  SAFE,
  SAFE_PROXY_FACTORY,
  SHORT_TX_EXECUTION_DELAY,
  WETH
} from 'script/Constants.s.sol';

contract BasicTest is Test {
  uint256 internal constant _FORK_BLOCK = 18_920_905;

  address internal constant _OWNER = address(0xc0ffee);

  ISimpleActions.SimpleAction internal _simpleAction;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), _FORK_BLOCK);

    // Deploy the Safe contract
    address[] memory _owners = new address[](1);
    _owners[0] = _OWNER;

    address _safeProxy = address(SafeProxyFactory(SAFE_PROXY_FACTORY).createProxyWithNonce(SAFE, bytes(''), 1));

    ISafe _safe = ISafe(payable(_safeProxy));

    _safe.setup({
      _owners: _owners,
      _threshold: 1,
      to: address(0),
      data: bytes(''),
      fallbackHandler: address(0),
      paymentToken: address(0),
      payment: 0,
      paymentReceiver: payable(address(0))
    });

    // Deploy the SafeEntrypoint contract
    SafeEntrypointFactory _safeEntrypointFactory = new SafeEntrypointFactory(MULTI_SEND_CALL_ONLY);
    SafeEntrypoint _safeEntrypoint = SafeEntrypoint(
      _safeEntrypointFactory.createSafeEntrypoint(
        address(_safe), SHORT_TX_EXECUTION_DELAY, LONG_TX_EXECUTION_DELAY, DEFAULT_TX_EXPIRY_DELAY
      )
    );

    // Deploy SimpleAction contract
    ISimpleActions.SimpleAction[] memory _simpleActions = new ISimpleActions.SimpleAction[](2);
    _simpleActions[0] = ISimpleActions.SimpleAction({target: WETH, signature: 'deposit()', data: bytes(''), value: 1});
    _simpleActions[1] = ISimpleActions.SimpleAction({
      target: WETH,
      signature: 'transfer(address,uint256)',
      data: abi.encode(_OWNER, 1),
      value: 0
    });

    SimpleActionsFactory _simpleActionsFactory = new SimpleActionsFactory();
    address _actionsBuilder = _simpleActionsFactory.createSimpleActions(_simpleActions);

    // Allow the SafeEntrypoint to call the SimpleActions contract
    uint256 _approvalDuration = block.timestamp + 1 days;

    vm.prank(address(_safe));
    _safeEntrypoint.approveActionsBuilder(_actionsBuilder, _approvalDuration);

    vm.startPrank(_OWNER);

    // Queue the transaction
    uint256 _txId = _safeEntrypoint.queueTransaction(_actionsBuilder, DEFAULT_TX_EXPIRY_DELAY);

    // Wait for the timelock period
    vm.warp(block.timestamp + SHORT_TX_EXECUTION_DELAY);

    // Get and approve the Safe transaction hash
    bytes32 _safeTxHash = _safeEntrypoint.getSafeTransactionHash(_txId);
    _safe.approveHash(_safeTxHash);

    // Execute the transaction
    vm.deal(_OWNER, 1 ether);
    _safeEntrypoint.executeTransaction{value: 1}(_txId);
  }

  function test_executeTransaction() public {}
}
