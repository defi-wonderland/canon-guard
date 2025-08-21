// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from 'forge-std/Script.sol';

import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';
import {ISafeEntrypointFactory} from 'interfaces/factories/ISafeEntrypointFactory.sol';

import {Constants} from 'script/Constants.sol';

contract DeployEntrypoint is Constants, Script {
  // ~~~ ENTRYPOINT ~~~
  ISafeEntrypoint public safeEntrypoint;

  function deployEntrypoint() public {
    vm.startBroadcast();

    // Deploy the SafeEntrypoint contract
    safeEntrypoint = ISafeEntrypoint(
      ISafeEntrypointFactory(0x966e7066d8B498AaC6ad6642b02dA3B545d85bFE).createSafeEntrypoint(
        0x3935C871e4f33EfE65400A010954024Ed3E352f2,
        0,
        120, // 2 minutes
        3600, // 1 hour
        MAX_APPROVAL_DURATION, // 4 years
        0xBad58e133138549936D2576ebC33251bE841d3e9,
        0xBad58e133138549936D2576ebC33251bE841d3e9
      )
    );

    vm.stopBroadcast();
  }
}
