// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from 'forge-std/Script.sol';

import {OnlyEntrypointGuard} from 'contracts/OnlyEntrypointGuard.sol';

import {IOnlyEntrypointGuard} from 'interfaces/IOnlyEntrypointGuard.sol';
import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';

import {Constants} from 'script/Constants.sol';

contract DeployEntrypoint is Constants, Script {
  // ~~~ ENTRYPOINT ~~~
  ISafeEntrypoint public safeEntrypoint;

  // ~~~ GUARD ~~~
  IOnlyEntrypointGuard public onlyEntrypointGuard;

  function deployEntrypoint() public {
    vm.startBroadcast();

    // Deploy the SafeEntrypoint contract
    safeEntrypoint = ISafeEntrypoint(
      SAFE_ENTRYPOINT_FACTORY.createSafeEntrypoint(
        address(SAFE_PROXY), SHORT_TX_EXECUTION_DELAY, LONG_TX_EXECUTION_DELAY, DEFAULT_TX_EXPIRY_DELAY
      )
    );

    // Deploy the OnlyEntrypointGuard contract
    onlyEntrypointGuard =
      new OnlyEntrypointGuard(address(safeEntrypoint), EMERGENCY_CALLER, address(MULTI_SEND_CALL_ONLY));

    vm.stopBroadcast();
  }
}
