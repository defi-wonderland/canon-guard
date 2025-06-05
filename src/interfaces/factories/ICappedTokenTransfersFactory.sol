// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/**
 * @title ICappedTokenTransfersFactory
 * @notice Interface for the CappedTokenTransfersFactory contract
 */
interface ICappedTokenTransfersFactory {
  // ~~~ FACTORY METHODS ~~~

  /**
   * @notice Creates a CappedTokenTransfers contract
   * @param _safe The Gnosis Safe contract address
   * @param _token The token contract address
   * @param _cap The cap for the token transfers
   * @param _epochLength The epoch length for the token transfers
   * @return _cappedTokenTransfers The CappedTokenTransfers contract address
   */
  function createCappedTokenTransfers(
    address _safe,
    address _token,
    uint256 _cap,
    uint256 _epochLength
  ) external returns (address _cappedTokenTransfers);
}
