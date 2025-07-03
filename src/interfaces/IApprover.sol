// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {ISafeEntrypoint} from 'src/interfaces/ISafeEntrypoint.sol';

interface IApprover {
  /**
   * @notice Emitted when a transaction is approved
   * @param _sender The address of the sender
   * @param _actionBuilder The address of the action builder
   * @param _safeNonce The nonce of the Safe transaction
   */
  event TxApproved(address indexed _sender, address _actionBuilder, uint256 _safeNonce);

  /**
   * @notice Emitted when the sender is not the EOA itself
   */
  error InvalidSender();

  /**
   * @notice Approves a transaction with the given action builder and safe nonce
   * @param _actionBuilder The address of the action builder
   * @param _safeNonce The nonce of the Safe transaction
   */
  function approveTx(address _actionBuilder, uint256 _safeNonce) external;

  /**
   * @notice Returns the address of the SafeEntrypoint contract
   * @return _entrypoint The address of the SafeEntrypoint contract
   */
  function ENTRYPOINT() external view returns (ISafeEntrypoint _entrypoint);

  /**
   * @notice Returns the address of the Safe contract
   * @return _safe The address of the Safe contract
   */
  function SAFE() external view returns (ISafe _safe);
}
