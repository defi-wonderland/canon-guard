// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {CappedTokenTransfers} from 'contracts/actions/CappedTokenTransfers.sol';

import {ICappedTokenTransfersFactory} from 'interfaces/factories/ICappedTokenTransfersFactory.sol';

/**
 * @title CappedTokenTransfersFactory
 * @notice Contract that deploys CappedTokenTransfers contracts
 */
contract CappedTokenTransfersFactory is ICappedTokenTransfersFactory {
  // ~~~ FACTORY METHODS ~~~

  /// @inheritdoc ICappedTokenTransfersFactory
  function createCappedTokenTransfers(
    address _safe,
    address _token,
    uint256 _cap,
    uint256 _epochLength
  ) external returns (address _cappedTokenTransfers) {
    _cappedTokenTransfers = address(new CappedTokenTransfers(_safe, _token, _cap, _epochLength));
  }
}
