// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Test} from 'forge-std/Test.sol';

import {DeployEntrypoint} from 'script/DeployEntrypoint.s.sol';
import {DeploySaferSafe} from 'script/DeploySaferSafe.s.sol';

import {OptimismConstants} from 'script/Constants.sol';

abstract contract IntegrationOptimismBase is DeploySaferSafe, DeployEntrypoint, OptimismConstants, Test {
  uint256 internal constant _OPTIMISM_FORK_BLOCK = 118_920_905;

  address[] internal _safeOwners;
  uint256 internal _safeThreshold;

  function setUp() public virtual {
    vm.createSelectFork(vm.rpcUrl('optimism'), _OPTIMISM_FORK_BLOCK);

    // Get the Safe owners
    _safeOwners = SAFE_PROXY.getOwners();
    // Get the Safe threshold
    _safeThreshold = SAFE_PROXY.getThreshold();

    // Deploy the SaferSafe factory contracts
    deploySaferSafe();

    // Deploy the SafeEntrypoint and OnlyEntrypointGuard contracts
    deployEntrypoint();

    // Set the OnlyEntrypointGuard as the Safe guard
    vm.prank(address(SAFE_PROXY));
    SAFE_PROXY.setGuard(address(onlyEntrypointGuard));
  }
}
