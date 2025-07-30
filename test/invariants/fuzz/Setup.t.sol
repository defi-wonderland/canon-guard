// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {ISafe, Safe} from '@safe-smart-account/Safe.sol';
import {SafeProxyFactory} from '@safe-smart-account/proxies/SafeProxyFactory.sol';

import {HandlersEntryPoint} from './HandlersEntryPoint.t.sol';
import {MultiSendCallOnly} from './utils/MultiSendCallOnly.sol';
import {SafeEntrypoint} from 'contracts/SafeEntrypoint.sol';

import {AllowanceClaimorFactory} from 'contracts/factories/AllowanceClaimorFactory.sol';
import {CappedTokenTransfersHubFactory} from 'contracts/factories/CappedTokenTransfersHubFactory.sol';
import {SafeEntrypointFactory} from 'contracts/factories/SafeEntrypointFactory.sol';
import {SimpleActionsFactory} from 'contracts/factories/SimpleActionsFactory.sol';
import {SimpleTransfersFactory} from 'contracts/factories/SimpleTransfersFactory.sol';

import {Constants} from 'script/Constants.sol';

contract Setup is Test, Constants {
  // Existing contracts
  MultiSendCallOnly internal _multiSendCallOnly;
  SafeProxyFactory internal _safeProxyFactory;
  Safe internal _safeSingleton;
  Safe internal _safe;

  SafeEntrypointFactory internal safeEntrypointFactory;
  SafeEntrypoint internal safeEntrypoint;

  AllowanceClaimorFactory allowanceClaimorFactory;
  CappedTokenTransfersHubFactory cappedTokenTransfersHubFactory;
  SimpleActionsFactory simpleActionsFactory;
  SimpleTransfersFactory simpleTransfersFactory;

  HandlersEntryPoint handlersEntryPoint;

  address[] internal _signers;

  function setUp() public {
    _safeProxyFactory = new SafeProxyFactory();
    _safeSingleton = new Safe();
    _safe = Safe(payable(_safeProxyFactory.createProxyWithNonce(address(_safeSingleton), bytes(''), 1)));

    _signers = new address[](5);
    _signers[0] = makeAddr('signer1');
    _signers[1] = makeAddr('signer2');
    _signers[2] = makeAddr('signer3');
    _signers[3] = makeAddr('signer4');
    _signers[4] = makeAddr('signer5');

    _safe.setup({
      _owners: _signers,
      _threshold: 3,
      to: address(0),
      data: bytes(''),
      fallbackHandler: address(0),
      paymentToken: address(0),
      payment: 0,
      paymentReceiver: payable(address(0))
    });

    safeEntrypointFactory = new SafeEntrypointFactory(address(_multiSendCallOnly));
    safeEntrypoint = SafeEntrypoint(
      safeEntrypointFactory.createSafeEntrypoint(
        address(_safe),
        SHORT_TX_EXECUTION_DELAY,
        LONG_TX_EXECUTION_DELAY,
        TX_EXPIRY_DELAY,
        MAX_APPROVAL_DURATION,
        EMERGENCY_TRIGGER,
        EMERGENCY_CALLER
      )
    );

    vm.prank(address(_safe));
    _safe.setGuard(address(safeEntrypoint));

    allowanceClaimorFactory = new AllowanceClaimorFactory();
    cappedTokenTransfersHubFactory = new CappedTokenTransfersHubFactory();
    simpleActionsFactory = new SimpleActionsFactory();
    simpleTransfersFactory = new SimpleTransfersFactory();

    handlersEntryPoint = new HandlersEntryPoint(safeEntrypoint, safeEntrypointFactory, _safe, _safeOwner);
    // targetContract(address(safeEntrypoint));
    targetContract(address(handlersEntryPoint));
  }
}
