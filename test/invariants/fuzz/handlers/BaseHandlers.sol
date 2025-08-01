// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Safe, SafeEntrypoint, SafeEntrypointFactory} from '../Setup.t.sol';

import {ActionTarget} from '../utils/ActionTarget.sol';

import {AllowanceClaimorFactory} from 'contracts/factories/AllowanceClaimorFactory.sol';
import {ApproveActionFactory} from 'contracts/factories/ApproveActionFactory.sol';
import {CappedTokenTransfersHubFactory} from 'contracts/factories/CappedTokenTransfersHubFactory.sol';
import {EverclearTokenConversionFactory} from 'contracts/factories/EverclearTokenConversionFactory.sol';
import {EverclearTokenStakeFactory} from 'contracts/factories/EverclearTokenStakeFactory.sol';
import {OPxActionFactory} from 'contracts/factories/OPxActionFactory.sol';
import {SimpleActionsFactory} from 'contracts/factories/SimpleActionsFactory.sol';
import {SimpleTransfersFactory} from 'contracts/factories/SimpleTransfersFactory.sol';
import {Test} from 'forge-std/Test.sol';
import {ISimpleActions} from 'interfaces/actions-builders/ISimpleActions.sol';

/// @notice Base contract for all handlers, include ghost storage and constructor
contract BaseHandlers is Test {
  bool initialized;

  SafeEntrypoint public safeEntrypoint;
  SafeEntrypointFactory public safeEntrypointFactory;
  Safe public safe;

  AllowanceClaimorFactory public allowanceClaimorFactory;
  ApproveActionFactory public approveActionFactory;
  CappedTokenTransfersHubFactory public cappedTokenTransfersHubFactory;
  EverclearTokenConversionFactory public everclearTokenConversionFactory;
  EverclearTokenStakeFactory public everclearTokenStakeFactory;
  OPxActionFactory public opxActionFactory;
  SimpleActionsFactory public simpleActionsFactory;
  SimpleTransfersFactory public simpleTransfersFactory;

  mapping(bytes32 => address) public ghost_hashToActionsBuilder;
  bytes32[] public ghost_hashes;

  ActionTarget public actionTarget;

  address[] public signers;
  address public currentSigner;

  modifier usingSigner(uint256 _seed) {
    currentSigner = signers[_seed % signers.length];
    vm.startPrank(currentSigner);
    _;
    vm.stopPrank();
  }

  constructor(
    SafeEntrypoint __safeEntrypoint,
    SafeEntrypointFactory __safeEntrypointFactory,
    Safe __safe,
    address[] memory __signers
  ) {
    safeEntrypoint = __safeEntrypoint;
    safeEntrypointFactory = __safeEntrypointFactory;
    safe = __safe;
    signers = __signers;
    actionTarget = new ActionTarget();

    allowanceClaimorFactory = new AllowanceClaimorFactory();
    approveActionFactory = new ApproveActionFactory();
    cappedTokenTransfersHubFactory = new CappedTokenTransfersHubFactory();
    everclearTokenConversionFactory = new EverclearTokenConversionFactory();
    everclearTokenStakeFactory = new EverclearTokenStakeFactory();
    opxActionFactory = new OPxActionFactory();
    simpleActionsFactory = new SimpleActionsFactory();
    simpleTransfersFactory = new SimpleTransfersFactory();
  }
}
