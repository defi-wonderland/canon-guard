// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from 'forge-std/Script.sol';

import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';

import {Constants} from 'script/Constants.sol';

contract DeployEntrypoint is Constants, Script {
  // ~~~ ENTRYPOINT ~~~
  ISafeEntrypoint public safeEntrypoint;

  function deployEntrypoint() public {
    vm.startBroadcast();

    // Deploy the SafeEntrypoint contract
    safeEntrypoint = ISafeEntrypoint(
      SAFE_ENTRYPOINT_FACTORY.createSafeEntrypoint(
        address(SAFE_PROXY),
        SHORT_TX_EXECUTION_DELAY,
        LONG_TX_EXECUTION_DELAY,
        TX_EXPIRY_DELAY,
        EMERGENCY_TRIGGER,
        EMERGENCY_CALLER
      )
    );

    vm.stopBroadcast();
  }
}
