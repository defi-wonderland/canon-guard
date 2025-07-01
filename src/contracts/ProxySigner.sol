// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafe} from '@safe-smart-account/interfaces/ISafe.sol';
import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';
import {Ownable} from 'solady/auth/Ownable.sol';

import {ECDSA} from 'solady/utils/ECDSA.sol';
import {EIP712} from 'solady/utils/EIP712.sol';

contract ProxySigner is Ownable, EIP712 {
  struct Tx {
    address actionBuilder;
    uint256 safeNonce;
  }

  ISafeEntrypoint public immutable ENTRYPOINT;
  ISafe public immutable SAFE;
  bytes32 constant TX_TYPEHASH = keccak256('Tx(address actionBuilder,uint256 safeNonce)');

  constructor(address _entrypoint, address _owner) {
    if (_entrypoint == address(0) || _owner == address(0)) revert('ProxySigner: invalid address');
    _initializeOwner(_owner);
    ENTRYPOINT = ISafeEntrypoint(_entrypoint);
    SAFE = ENTRYPOINT.SAFE();
  }

  function approve(bytes calldata _signature, address _actionBuilder, uint256 _safeNonce) external onlyOwner {
    // Verify the signature
    bytes32 _digest = _getDigest(Tx({actionBuilder: _actionBuilder, safeNonce: _safeNonce}));
    address _signer = ECDSA.recover(_digest, _signature);
    if (_signer != owner()) revert('ProxySigner: invalid signature');

    // Get tx hash
    bytes32 _txHash = ENTRYPOINT.getSafeTransactionHash(_actionBuilder, _safeNonce);

    // Approve the tx
    SAFE.approveHash(_txHash);
  }

  function _domainNameAndVersion() internal pure virtual override returns (string memory name, string memory version) {
    name = 'ProxySigner';
    version = '1';
  }

  function _getDigest(Tx memory _tx) internal view virtual returns (bytes32 _digest) {
    _digest = _hashTypedData(_hashStruct(_tx));
  }

  function _hashStruct(Tx memory _tx) internal view virtual returns (bytes32) {
    // TODO: re-check if this is correctly implemented
    return keccak256(abi.encode(TX_TYPEHASH, _tx.actionBuilder, _tx.safeNonce));
  }
}
