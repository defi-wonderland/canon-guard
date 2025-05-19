// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Script} from 'forge-std/Script.sol';

import {AllowanceClaimorFactory} from 'contracts/factories/AllowanceClaimorFactory.sol';
import {CappedTokenTransfersFactory} from 'contracts/factories/CappedTokenTransfersFactory.sol';
import {SafeEntrypointFactory} from 'contracts/factories/SafeEntrypointFactory.sol';
import {SimpleActionsFactory} from 'contracts/factories/SimpleActionsFactory.sol';
import {SimpleTransfersFactory} from 'contracts/factories/SimpleTransfersFactory.sol';

import {IAllowanceClaimorFactory} from 'interfaces/factories/IAllowanceClaimorFactory.sol';
import {ICappedTokenTransfersFactory} from 'interfaces/factories/ICappedTokenTransfersFactory.sol';
import {ISafeEntrypointFactory} from 'interfaces/factories/ISafeEntrypointFactory.sol';
import {ISimpleActionsFactory} from 'interfaces/factories/ISimpleActionsFactory.sol';
import {ISimpleTransfersFactory} from 'interfaces/factories/ISimpleTransfersFactory.sol';

import {MULTI_SEND_CALL_ONLY} from 'script/Constants.s.sol';

contract DeploySaferSafe is Script {
  // ~~~ FACTORIES ~~~
  ISafeEntrypointFactory public safeEntrypointFactory;
  IAllowanceClaimorFactory public allowanceClaimorFactory;
  ICappedTokenTransfersFactory public cappedTokenTransfersFactory;
  ISimpleActionsFactory public simpleActionsFactory;
  ISimpleTransfersFactory public simpleTransfersFactory;

  function run() public {
    vm.startBroadcast();

    // Deploy the SafeEntrypointFactory contract
    safeEntrypointFactory = new SafeEntrypointFactory(MULTI_SEND_CALL_ONLY);

    // Deploy the AllowanceClaimorFactory contract
    allowanceClaimorFactory = new AllowanceClaimorFactory();
    // Deploy the CappedTokenTransfersFactory contract
    cappedTokenTransfersFactory = new CappedTokenTransfersFactory();
    // Deploy the SimpleActionsFactory contract
    simpleActionsFactory = new SimpleActionsFactory();
    // Deploy the SimpleTransfersFactory contract
    simpleTransfersFactory = new SimpleTransfersFactory();

    vm.stopBroadcast();
  }
}
