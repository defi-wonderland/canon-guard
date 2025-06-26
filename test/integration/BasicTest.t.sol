// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Test} from 'forge-std/Test.sol';

import {OnlyEntrypointGuard} from 'contracts/OnlyEntrypointGuard.sol';

import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';
import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';
import {ISimpleActions} from 'interfaces/actions-builders/ISimpleActions.sol';

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';

import {DeploySaferSafe} from 'script/DeploySaferSafe.s.sol';

import {EthereumConstants} from 'script/Constants.sol';

contract IntegrationBasicTest is DeploySaferSafe, EthereumConstants, Test {
  uint256 internal constant _ETHEREUM_FORK_BLOCK = 18_920_905;

  // ~~~ SAFE ~~~
  ISafe internal _safeProxy;
  address internal _safeOwner;
  uint256 internal _safeThreshold;

  // ~~~ ENTRYPOINT ~~~
  ISafeEntrypoint internal _safeEntrypoint;

  // ~~~ GUARD ~~~
  IOnlyEntrypointGuard internal _onlyEntrypointGuard;

  // ~~~ ACTIONS ~~~
  address internal _actionsBuilder;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), _ETHEREUM_FORK_BLOCK);

    // Deploy the SafeProxy contract
    _safeProxy = ISafe(address(SAFE_PROXY_FACTORY.createProxyWithNonce(address(SAFE), bytes(''), 1)));

    _safeOwner = makeAddr('safeOwner');
    vm.deal(_safeOwner, 1 ether);

    address[] memory _safeOwners = new address[](1);
    _safeOwners[0] = _safeOwner;
    _safeThreshold = 1;

    _safeProxy.setup({
      _owners: _safeOwners,
      _threshold: _safeThreshold,
      to: address(0),
      data: bytes(''),
      fallbackHandler: address(0),
      paymentToken: address(0),
      payment: 0,
      paymentReceiver: payable(address(0))
    });

    // Deploy the SaferSafe factory contracts
    deploySaferSafe();

    // Deploy the SafeEntrypoint contract
    _safeEntrypoint = ISafeEntrypoint(
      safeEntrypointFactory.createSafeEntrypoint(
        address(_safeProxy),
        SHORT_TX_EXECUTION_DELAY,
        LONG_TX_EXECUTION_DELAY,
        TX_EXPIRY_DELAY,
        EMERGENCY_TRIGGER,
        EMERGENCY_CALLER
      )
    );

    // Deploy the OnlyEntrypointGuard contract
    _onlyEntrypointGuard = new OnlyEntrypointGuard(address(_safeEntrypoint), EMERGENCY_CALLER);

    vm.prank(address(_safeProxy));
    _safeProxy.setGuard(address(_onlyEntrypointGuard));

    // Deploy the SimpleActions contract
    ISimpleActions.SimpleAction memory _depositAction =
      ISimpleActions.SimpleAction({target: address(WETH), signature: 'deposit()', data: bytes(''), value: 1});
    ISimpleActions.SimpleAction memory _transferAction = ISimpleActions.SimpleAction({
      target: address(WETH),
      signature: 'transfer(address,uint256)',
      data: abi.encode(_safeOwner, 1),
      value: 0
    });

    ISimpleActions.SimpleAction[] memory _simpleActions = new ISimpleActions.SimpleAction[](2);
    _simpleActions[0] = _depositAction;
    _simpleActions[1] = _transferAction;

    _actionsBuilder = simpleActionsFactory.createSimpleActions(_simpleActions);
  }

  function test_ExecuteTransaction() public {
    // Allow the SafeEntrypoint to call the SimpleActions contract
    uint256 _approvalDuration = block.timestamp + 1 days;

    vm.prank(address(_safeProxy));
    _safeEntrypoint.approveActionsBuilder(_actionsBuilder, _approvalDuration);

    vm.startPrank(_safeOwner);

    // Queue the transaction
    uint256 _txId = _safeEntrypoint.queueTransaction(_actionsBuilder);

    // Wait for the timelock period
    vm.warp(block.timestamp + SHORT_TX_EXECUTION_DELAY);

    // Get and approve the Safe transaction hash
    bytes32 _safeTxHash = _safeEntrypoint.getSafeTransactionHash(_txId);
    _safeProxy.approveHash(_safeTxHash);

    // Execute the transaction
    _safeEntrypoint.executeTransaction{value: 1}(_txId);
  }
}
