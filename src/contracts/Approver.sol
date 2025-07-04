// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {IApprover} from 'src/interfaces/IApprover.sol';
import {ISafeEntrypoint} from 'src/interfaces/ISafeEntrypoint.sol';

contract Approver is IApprover {
  /// @inheritdoc IApprover
  ISafeEntrypoint public immutable ENTRYPOINT;

  /// @inheritdoc IApprover
  ISafe public immutable SAFE;

  /**
   * @notice Constructor of the contract
   * @param _entrypoint The address of the SafeEntrypoint contract
   */
  constructor(address _entrypoint) {
    ENTRYPOINT = ISafeEntrypoint(_entrypoint);
    SAFE = ENTRYPOINT.SAFE();
  }

  /// @inheritdoc IApprover
  function approveTx(address _actionBuilder, uint256 _safeNonce) external {
    if (msg.sender != address(this)) revert InvalidSender();

    bytes32 _safeTxHash = ENTRYPOINT.getSafeTransactionHash(_actionBuilder, _safeNonce);
    SAFE.approveHash(_safeTxHash);

    emit TxApproved(_actionBuilder, _safeNonce, _safeTxHash);
  }
}
