// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OnlyEntrypointGuard} from 'contracts/OnlyEntrypointGuard.sol';

contract OnlyEntrypointGuardForTest is OnlyEntrypointGuard {
  constructor(
    address _entrypoint,
    address _emergencyCaller,
    address _multiSendCallOnly
  ) OnlyEntrypointGuard(_entrypoint, _emergencyCaller, _multiSendCallOnly) {}
}
