// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {SafeEntrypoint} from 'contracts/SafeEntrypoint.sol';

import {ISafeEntrypointFactory} from 'interfaces/factories/ISafeEntrypointFactory.sol';

/**
 * @title SafeEntrypointFactory
 * @notice Contract that deploys SafeEntrypoint contracts
 */
contract SafeEntrypointFactory is ISafeEntrypointFactory {
  // ~~~ STORAGE ~~~

  /// @inheritdoc ISafeEntrypointFactory
  address public immutable MULTI_SEND_CALL_ONLY;

  // ~~~ CONSTRUCTOR ~~~

  /**
   * @notice Constructor that sets up the MultiSendCallOnly contract
   * @param _multiSendCallOnly The MultiSendCallOnly contract address
   */
  constructor(address _multiSendCallOnly) {
    MULTI_SEND_CALL_ONLY = _multiSendCallOnly;
  }

  // ~~~ FACTORY METHODS ~~~

  /// @inheritdoc ISafeEntrypointFactory
  function createSafeEntrypoint(
    address _safe,
    uint256 _shortTxExecutionDelay,
    uint256 _longTxExecutionDelay,
    uint256 _txExpiryDelay,
    uint256 _maxApprovalDuration,
    address _emergencyTrigger,
    address _emergencyCaller
  ) external returns (address _safeEntrypoint) {
    _safeEntrypoint = address(
      new SafeEntrypoint(
        _safe,
        MULTI_SEND_CALL_ONLY,
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );
  }
}
