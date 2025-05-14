// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from 'forge-std/Script.sol';

import {OnlyEntrypointGuard} from 'contracts/OnlyEntrypointGuard.sol';
import {SafeEntrypoint} from 'contracts/SafeEntrypoint.sol';

import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';
import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';
import {ISafeEntrypointFactory} from 'interfaces/factories/ISafeEntrypointFactory.sol';

import {
  DEFAULT_TX_EXPIRY_DELAY,
  EMERGENCY_CALLER,
  LONG_TX_EXECUTION_DELAY,
  MULTI_SEND_CALL_ONLY,
  SAFE_ENTRYPOINT_FACTORY,
  SHORT_TX_EXECUTION_DELAY,
  WONDERLAND_SAFE
} from 'script/Constants.s.sol';

contract DeployWonderlandEntrypoint is Script {
  // ~~~ ENTRYPOINT ~~~
  ISafeEntrypoint public wonderlandEntrypoint;

  // ~~~ GUARD ~~~
  IOnlyEntrypointGuard public wonderlandGuard;

  function run() public {
    vm.startBroadcast();

    // Deploy the SafeEntrypoint contract
    wonderlandEntrypoint = ISafeEntrypoint(
      ISafeEntrypointFactory(SAFE_ENTRYPOINT_FACTORY).createSafeEntrypoint(
        WONDERLAND_SAFE, SHORT_TX_EXECUTION_DELAY, LONG_TX_EXECUTION_DELAY, DEFAULT_TX_EXPIRY_DELAY
      )
    );

    // Deploy the OnlyEntrypointGuard contract
    wonderlandGuard = new OnlyEntrypointGuard(address(wonderlandEntrypoint), EMERGENCY_CALLER, MULTI_SEND_CALL_ONLY);

    vm.stopBroadcast();
  }
}
