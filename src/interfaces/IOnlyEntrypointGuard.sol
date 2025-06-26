// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ITransactionGuard} from '@safe-smart-account/base/GuardManager.sol';

/**
 * @title IOnlyEntrypointGuard
 * @notice Interface for the OnlyEntrypointGuard contract
 */
interface IOnlyEntrypointGuard is ITransactionGuard {
  // ~~~ ERRORS ~~~

  /**
   * @notice Thrown when a transaction is attempted by an unauthorized sender
   * @param _sender The unauthorized sender address
   */
  error UnauthorizedSender(address _sender);
}
