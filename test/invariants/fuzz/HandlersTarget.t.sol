// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './handlers/BaseHandlers.sol';

import {HandlersAllowanceClaimor} from './handlers/HandlersAllowanceClaimor.t.sol';
import {HandlersApprove} from './handlers/HandlersApprove.t.sol';
import {HandlersApproveAction} from './handlers/HandlersApproveAction.t.sol';
import {HandlersCappedTokenTransfers} from './handlers/HandlersCappedTokenTransfers.t.sol';
import {HandlersEverclearTokenConversion} from './handlers/HandlersEverclearTokenConversion.t.sol';
import {HandlersEverclearTokenStake} from './handlers/HandlersEverclearTokenStake.t.sol';
import {HandlersOPxAction} from './handlers/HandlersOPxAction.t.sol';
import {HandlersReconfigBaseParam} from './handlers/HandlersReconfigBaseParam.t.sol';
import {HandlersSimpleActions} from './handlers/HandlersSimpleActions.t.sol';
import {HandlersSimpleTransfers} from './handlers/HandlersSimpleTransfers.t.sol';

contract HandlersTarget is
  HandlersReconfigBaseParam,
  HandlersSimpleActions,
  HandlersApprove,
  HandlersAllowanceClaimor,
  HandlersApproveAction,
  HandlersCappedTokenTransfers,
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
}
