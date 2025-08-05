// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './handlers/BaseHandlers.sol';

import {HandlersAllowanceClaimor} from './handlers/HandlersAllowanceClaimor.t.sol';
import {HandlersCappedTokenTransfersHub} from './handlers/HandlersCappedTokenTransfersHub.t.sol';
import {HandlersEverclearTokenConversion} from './handlers/HandlersEverclearTokenConversion.t.sol';
import {HandlersEverclearTokenStake} from './handlers/HandlersEverclearTokenStake.t.sol';
import {HandlersOPxAction} from './handlers/HandlersOPxAction.t.sol';

import {HandlersSafeEntrypoint} from './handlers/HandlersSafeEntrypoint.t.sol';
import {HandlersSimpleActions} from './handlers/HandlersSimpleActions.t.sol';
import {HandlersSimpleTransfers} from './handlers/HandlersSimpleTransfers.t.sol';

contract HandlersTarget is
  HandlersSafeEntrypoint,
  HandlersSimpleActions,
  HandlersAllowanceClaimor,
  HandlersCappedTokenTransfersHub,
  HandlersEverclearTokenConversion,
  HandlersEverclearTokenStake,
  HandlersOPxAction,
  HandlersSimpleTransfers
{
  constructor(
    SafeEntrypoint __safeEntrypoint,
    SafeEntrypointFactory __safeEntrypointFactory,
    Safe __safe,
    address[] memory __signers
  ) BaseHandlers(__safeEntrypoint, __safeEntrypointFactory, __safe, __signers) {}

  function getGhostHashesLength() public view returns (uint256) {
    return ghost_hashes.length;
  }

  function getGhostHash(uint256 index) public view returns (bytes32) {
    return ghost_hashes[index];
  }

  function getCreatedHubs() public view returns (address[] memory) {
    return createdHubs;
  }

  function getCreatedHubsLength() public view returns (uint256) {
    return createdHubs.length;
  }
}
