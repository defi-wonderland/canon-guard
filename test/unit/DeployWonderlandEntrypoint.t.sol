// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Test} from 'forge-std/Test.sol';

import {DeployWonderlandEntrypoint} from 'script/DeployWonderlandEntrypoint.s.sol';

import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';
import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';

import {
  DEFAULT_TX_EXPIRY_DELAY,
  EMERGENCY_CALLER,
  LONG_TX_EXECUTION_DELAY,
  MULTI_SEND_CALL_ONLY,
  SAFE_ENTRYPOINT_FACTORY,
  SHORT_TX_EXECUTION_DELAY,
  WONDERLAND_SAFE
} from 'script/Constants.s.sol';

contract UnitDeployWonderlandEntrypoint is Test {
  DeployWonderlandEntrypoint public deployWonderlandEntrypoint;

  ISafeEntrypoint internal _ghost_safeEntrypoint;
  IOnlyEntrypointGuard internal _ghost_onlyEntrypointGuard;

  function setUp() public {
    // Deploy the DeployWonderlandEntrypoint contract
    deployWonderlandEntrypoint = new DeployWonderlandEntrypoint();

    // Deploy the SafeEntrypoint contract
    _ghost_safeEntrypoint = ISafeEntrypoint(
      deployCode(
        'SafeEntrypoint',
        abi.encode(
          WONDERLAND_SAFE,
          MULTI_SEND_CALL_ONLY,
          SHORT_TX_EXECUTION_DELAY,
          LONG_TX_EXECUTION_DELAY,
          DEFAULT_TX_EXPIRY_DELAY
        )
      )
    );

    // Deploy the SafeEntrypointFactory contract
    deployCodeTo('SafeEntrypointFactory', abi.encode(MULTI_SEND_CALL_ONLY), SAFE_ENTRYPOINT_FACTORY); // TODO: Remove once deployed
  }

  function test_WhenRun() public {
    // Run the deployment script
    deployWonderlandEntrypoint.run();

    // Get the deployed contracts
    ISafeEntrypoint _wonderlandEntrypoint = deployWonderlandEntrypoint.wonderlandEntrypoint();
    IOnlyEntrypointGuard _wonderlandGuard = deployWonderlandEntrypoint.wonderlandGuard();

    // Deploy the OnlyEntrypointGuard contract
    _ghost_onlyEntrypointGuard = IOnlyEntrypointGuard(
      deployCode('OnlyEntrypointGuard', abi.encode(_wonderlandEntrypoint, EMERGENCY_CALLER, MULTI_SEND_CALL_ONLY))
    );

    // It should deploy the SafeEntrypoint contract with correct args
    assertEq(address(_wonderlandEntrypoint).code, address(_ghost_safeEntrypoint).code);
    assertEq(address(_wonderlandEntrypoint.SAFE()), WONDERLAND_SAFE);
    assertEq(_wonderlandEntrypoint.MULTI_SEND_CALL_ONLY(), MULTI_SEND_CALL_ONLY);
    assertEq(_wonderlandEntrypoint.SHORT_TX_EXECUTION_DELAY(), SHORT_TX_EXECUTION_DELAY);
    assertEq(_wonderlandEntrypoint.LONG_TX_EXECUTION_DELAY(), LONG_TX_EXECUTION_DELAY);
    assertEq(_wonderlandEntrypoint.DEFAULT_TX_EXPIRY_DELAY(), DEFAULT_TX_EXPIRY_DELAY);

    // It should deploy the OnlyEntrypointGuard contract with correct args
    assertEq(address(_wonderlandGuard).code, address(_ghost_onlyEntrypointGuard).code);
    assertEq(_wonderlandGuard.ENTRYPOINT(), address(_wonderlandEntrypoint));
    assertEq(_wonderlandGuard.EMERGENCY_CALLER(), EMERGENCY_CALLER);
    assertEq(_wonderlandGuard.MULTI_SEND_CALL_ONLY(), MULTI_SEND_CALL_ONLY);
  }
}
