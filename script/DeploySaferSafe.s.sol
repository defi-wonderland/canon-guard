// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from 'forge-std/Script.sol';

import {AllowanceClaimorFactory} from 'contracts/factories/AllowanceClaimorFactory.sol';
import {CappedTokenTransfersHubFactory} from 'contracts/factories/CappedTokenTransfersHubFactory.sol';
import {SafeEntrypointFactory} from 'contracts/factories/SafeEntrypointFactory.sol';
import {SimpleActionsFactory} from 'contracts/factories/SimpleActionsFactory.sol';
import {SimpleTransfersFactory} from 'contracts/factories/SimpleTransfersFactory.sol';

import {IAllowanceClaimorFactory} from 'interfaces/factories/IAllowanceClaimorFactory.sol';
import {ICappedTokenTransfersHubFactory} from 'interfaces/factories/ICappedTokenTransfersHubFactory.sol';
import {ISafeEntrypointFactory} from 'interfaces/factories/ISafeEntrypointFactory.sol';
import {ISimpleActionsFactory} from 'interfaces/factories/ISimpleActionsFactory.sol';
import {ISimpleTransfersFactory} from 'interfaces/factories/ISimpleTransfersFactory.sol';

import {Constants} from 'script/Constants.sol';

contract DeploySaferSafe is Constants, Script {
  // ~~~ FACTORIES ~~~
  ISafeEntrypointFactory public safeEntrypointFactory;
  IAllowanceClaimorFactory public allowanceClaimorFactory;
  ICappedTokenTransfersHubFactory public cappedTokenTransfersHubFactory;
  ISimpleActionsFactory public simpleActionsFactory;
  ISimpleTransfersFactory public simpleTransfersFactory;

  function deploySaferSafe() public {
    vm.startBroadcast();

    // Deploy the SafeEntrypointFactory contract
    safeEntrypointFactory = new SafeEntrypointFactory(address(MULTI_SEND_CALL_ONLY));

    // Deploy the AllowanceClaimorFactory contract
    allowanceClaimorFactory = new AllowanceClaimorFactory();
    // Deploy the CappedTokenTransfersFactory contract
    // cappedTokenTransfersFactory = new CappedTokenTransfersFactory();
    // Deploy the SimpleActionsFactory contract
    simpleActionsFactory = new SimpleActionsFactory();
    // Deploy the SimpleTransfersFactory contract
    simpleTransfersFactory = new SimpleTransfersFactory();

    vm.stopBroadcast();
  }
}
