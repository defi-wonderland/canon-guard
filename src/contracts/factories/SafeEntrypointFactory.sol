// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {SafeEntrypoint} from 'contracts/SafeEntrypoint.sol';

import {ISafeEntrypointFactory} from 'interfaces/factories/ISafeEntrypointFactory.sol';

contract SafeEntrypointFactory is ISafeEntrypointFactory {
  address public immutable MULTI_SEND_CALL_ONLY;

  constructor(address _multiSendCallOnly) {
    MULTI_SEND_CALL_ONLY = _multiSendCallOnly;
  }

  function createSafeEntrypoint(
    address _safe,
    uint256 _shortTxExecutionDelay,
    uint256 _longTxExecutionDelay,
    uint256 _defaultTxExpiryDelay
  ) external returns (address _safeEntrypoint) {
    _safeEntrypoint = address(
      new SafeEntrypoint(
        _safe, MULTI_SEND_CALL_ONLY, _shortTxExecutionDelay, _longTxExecutionDelay, _defaultTxExpiryDelay
      )
    );
  }
}
