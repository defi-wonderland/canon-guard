// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BaseHandlers, Safe, SafeEntrypoint, SafeEntrypointFactory} from './BaseHandlers.sol';

/// Handler to approve a hash, by one of the signers (we don't assess the signature validation itself,
/// as its done by the Safe itself)
abstract contract HandlersApprove is BaseHandlers {
  function handler_approveHash(uint256 _signerSeed, uint256 _hashSeed) public usingSigner(_signerSeed) {
    if (ghost_hashes.length == 0) return; // avoid mod 0
    bytes32 _hash = ghost_hashes[_hashSeed % ghost_hashes.length];

    try safe.approveHash(_hash) {}
    catch {
      assertEq(_hash, bytes32(0));
    }
  }
}
