// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Test} from 'forge-std/Test.sol';

import {DeploySaferSafe} from 'script/DeploySaferSafe.s.sol';

import {AllowanceClaimorFactory} from 'contracts/factories/AllowanceClaimorFactory.sol';
import {CappedTokenTransfersHubFactory} from 'contracts/factories/CappedTokenTransfersHubFactory.sol';
import {SimpleActionsFactory} from 'contracts/factories/SimpleActionsFactory.sol';
import {SimpleTransfersFactory} from 'contracts/factories/SimpleTransfersFactory.sol';

import {IAllowanceClaimorFactory} from 'interfaces/factories/IAllowanceClaimorFactory.sol';
import {ICappedTokenTransfersHubFactory} from 'interfaces/factories/ICappedTokenTransfersHubFactory.sol';
import {ISafeEntrypointFactory} from 'interfaces/factories/ISafeEntrypointFactory.sol';
import {ISimpleActionsFactory} from 'interfaces/factories/ISimpleActionsFactory.sol';
import {ISimpleTransfersFactory} from 'interfaces/factories/ISimpleTransfersFactory.sol';

import {Constants} from 'script/Constants.sol';

contract UnitDeploySaferSafe is Constants, Test {
  DeploySaferSafe public deploySaferSafe;

  ISafeEntrypointFactory internal _ghost_safeEntrypointFactory;

  function setUp() public {
    // Deploy the DeploySaferSafe contract
    deploySaferSafe = new DeploySaferSafe();

    // Deploy the SafeEntrypointFactory contract
    _ghost_safeEntrypointFactory =
      ISafeEntrypointFactory(deployCode('SafeEntrypointFactory', abi.encode(MULTI_SEND_CALL_ONLY)));
  }

  function test_WhenRun() public {
    // Run the deployment script
    deploySaferSafe.deploySaferSafe();

    // Get the deployed contracts
    ISafeEntrypointFactory _safeEntrypointFactory = deploySaferSafe.safeEntrypointFactory();
    IAllowanceClaimorFactory _allowanceClaimorFactory = deploySaferSafe.allowanceClaimorFactory();
    ICappedTokenTransfersHubFactory _cappedTokenTransfersHubFactory = deploySaferSafe.cappedTokenTransfersHubFactory();
    ISimpleActionsFactory _simpleActionsFactory = deploySaferSafe.simpleActionsFactory();
    ISimpleTransfersFactory _simpleTransfersFactory = deploySaferSafe.simpleTransfersFactory();

    // It should deploy the SafeEntrypointFactory contract with correct args
    assertEq(address(_safeEntrypointFactory).code, address(_ghost_safeEntrypointFactory).code);
    assertEq(_safeEntrypointFactory.MULTI_SEND_CALL_ONLY(), address(MULTI_SEND_CALL_ONLY));

    // It should deploy the AllowanceClaimorFactory contract
    assertEq(address(_allowanceClaimorFactory).code, type(AllowanceClaimorFactory).runtimeCode);

    // It should deploy the CappedTokenTransfersHubFactory contract
    assertEq(address(_cappedTokenTransfersHubFactory).code, type(CappedTokenTransfersHubFactory).runtimeCode);

    // It should deploy the SimpleActionsFactory contract
    assertEq(address(_simpleActionsFactory).code, type(SimpleActionsFactory).runtimeCode);

    // It should deploy the SimpleTransfersFactory contract
    assertEq(address(_simpleTransfersFactory).code, type(SimpleTransfersFactory).runtimeCode);
  }
}
