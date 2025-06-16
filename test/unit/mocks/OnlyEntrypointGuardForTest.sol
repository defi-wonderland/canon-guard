// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OnlyEntrypointGuard} from 'contracts/OnlyEntrypointGuard.sol';

contract OnlyEntrypointGuardForTest is OnlyEntrypointGuard {
  constructor(address _entrypoint, address _emergencyCaller) OnlyEntrypointGuard(_entrypoint, _emergencyCaller) {}

  function isValidSignatureType(bytes memory _signatures) public pure returns (bool _isValid) {
    return _isValidSignatureType(_signatures);
  }
}
