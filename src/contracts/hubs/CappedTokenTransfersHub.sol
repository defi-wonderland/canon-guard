// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ICappedTokenTransfersHub} from 'interfaces/hubs/ICappedTokenTransfersHub.sol';
import {CREATE3} from 'solady/utils/CREATE3.sol';
import {SafeManageable} from 'src/contracts/SafeManageable.sol';
import {CappedTokenTransfers} from 'src/contracts/actions-builders/CappedTokenTransfers.sol';

contract CappedTokenTransfersHub is ICappedTokenTransfersHub, SafeManageable {
  address public immutable recipient;
  uint256 public immutable EPOCH_LENGTH;
  uint256 public immutable startingTimestamp;
  uint256 public currentEpoch;

  mapping(address _token => uint256 _cap) public cap;
  mapping(address _token => uint256 _totalSpent) public totalSpent;

  constructor(
    address _safe,
    address _recipient,
    address[] memory _tokens,
    uint256[] memory _caps,
    uint256 _epochLength
  ) SafeManageable(_safe) {
    recipient = _recipient;
    EPOCH_LENGTH = _epochLength;
    startingTimestamp = block.timestamp;

    for (uint256 i = 0; i < _tokens.length; i++) {
      cap[_tokens[i]] = _caps[i];
    }
  }

  function createNewChild(address _token, uint256 _amount) external isSafe returns (address _child) {
    // Deploy with create2 to have deterministic addresses, if the child already exists, it will revert

    bytes memory _initCode =
      abi.encodePacked(type(CappedTokenTransfers).creationCode, abi.encode(SAFE, _token, _amount, recipient));
    bytes32 _salt = keccak256(abi.encode(recipient, _token, _amount));

    _child = CREATE3.deployDeterministic(_initCode, _salt);

    emit NewChildCreated(_child);
  }

  function _isChild(address _child) internal view returns (bool _exists) {}

  function updateState(bytes memory _data) external isSafe {
    (uint256 _amount, address _token) = abi.decode(_data, (uint256, address));

    uint256 _currentEpoch = (block.timestamp - startingTimestamp) / EPOCH_LENGTH;

    // If we're in a new epoch, reset the spending
    if (_currentEpoch > currentEpoch) {
      delete totalSpent[_token];
      currentEpoch = _currentEpoch;
    }

    totalSpent[_token] += _amount;

    if (totalSpent[_token] > cap[_token]) {
      revert CapExceeded();
    }
  }
}
