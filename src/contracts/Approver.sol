// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {ISafeEntrypoint} from 'src/interfaces/ISafeEntrypoint.sol';

contract Approver {
  ISafeEntrypoint public immutable ENTRYPOINT;

  constructor(address _entrypoint) {
    ENTRYPOINT = ISafeEntrypoint(_entrypoint);
  }

  function approveTx(address _actionBuilder, uint256 _safeNonce) external {
    require(msg.sender == address(this));
    bytes32 _safeTxHash = ENTRYPOINT.getSafeTransactionHash(_actionBuilder, _safeNonce);
    ENTRYPOINT.SAFE().approveHash(_safeTxHash);
  }
}
