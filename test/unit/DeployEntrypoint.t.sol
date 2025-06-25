// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Test} from 'forge-std/Test.sol';

import {DeployEntrypoint} from 'script/DeployEntrypoint.s.sol';

import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';
import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';

import {Constants} from 'script/Constants.sol';

contract UnitDeployEntrypoint is Constants, Test {
  DeployEntrypoint public deployEntrypoint;

  ISafeEntrypoint internal _ghost_safeEntrypoint;
  IOnlyEntrypointGuard internal _ghost_onlyEntrypointGuard;

  function setUp() public {
    // Deploy the DeployEntrypoint contract
    deployEntrypoint = new DeployEntrypoint();

    // Deploy the SafeEntrypoint contract
    _ghost_safeEntrypoint = ISafeEntrypoint(
      deployCode(
        'SafeEntrypoint',
        abi.encode(SAFE_PROXY, MULTI_SEND_CALL_ONLY, SHORT_TX_EXECUTION_DELAY, LONG_TX_EXECUTION_DELAY, TX_EXPIRY_DELAY)
      )
    );

    // Deploy the SafeEntrypointFactory contract
    deployCodeTo('SafeEntrypointFactory', abi.encode(MULTI_SEND_CALL_ONLY), address(SAFE_ENTRYPOINT_FACTORY)); // TODO: Remove once deployed
  }

  function test_WhenRun() public {
    // Run the deployment script
    deployEntrypoint.deployEntrypoint();

    // Get the deployed contracts
    ISafeEntrypoint _safeEntrypoint = deployEntrypoint.safeEntrypoint();
    IOnlyEntrypointGuard _onlyEntrypointGuard = deployEntrypoint.onlyEntrypointGuard();

    // Deploy the OnlyEntrypointGuard contract
    _ghost_onlyEntrypointGuard = IOnlyEntrypointGuard(
      deployCode('OnlyEntrypointGuard', abi.encode(_safeEntrypoint, EMERGENCY_CALLER, MULTI_SEND_CALL_ONLY))
    );

    // It should deploy the SafeEntrypoint contract with correct args
    assertEq(address(_safeEntrypoint).code, address(_ghost_safeEntrypoint).code);
    assertEq(address(_safeEntrypoint.SAFE()), address(SAFE_PROXY));
    assertEq(_safeEntrypoint.MULTI_SEND_CALL_ONLY(), address(MULTI_SEND_CALL_ONLY));
    assertEq(_safeEntrypoint.SHORT_TX_EXECUTION_DELAY(), SHORT_TX_EXECUTION_DELAY);
    assertEq(_safeEntrypoint.LONG_TX_EXECUTION_DELAY(), LONG_TX_EXECUTION_DELAY);
    assertEq(_safeEntrypoint.TX_EXPIRY_DELAY(), TX_EXPIRY_DELAY);

    // It should deploy the OnlyEntrypointGuard contract with correct args
    assertEq(address(_onlyEntrypointGuard).code, address(_ghost_onlyEntrypointGuard).code);
    assertEq(_onlyEntrypointGuard.ENTRYPOINT(), address(_safeEntrypoint));
    assertEq(_onlyEntrypointGuard.EMERGENCY_CALLER(), EMERGENCY_CALLER);
    assertEq(_onlyEntrypointGuard.MULTI_SEND_CALL_ONLY(), address(MULTI_SEND_CALL_ONLY));
  }
}
