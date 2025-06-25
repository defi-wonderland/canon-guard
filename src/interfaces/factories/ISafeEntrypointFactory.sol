// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/**
 * @title ISafeEntrypointFactory
 * @notice Interface for the SafeEntrypointFactory contract
 */
interface ISafeEntrypointFactory {
  // ~~~ FACTORY METHODS ~~~

  /**
   * @notice Creates a SafeEntrypoint contract
   * @param _safe The Gnosis Safe contract address
   * @param _shortTxExecutionDelay The short transaction execution delay (in seconds)
   * @param _longTxExecutionDelay The long transaction execution delay (in seconds)
   * @param _txExpiryDelay The transaction expiry delay (in seconds after executable)
   * @return _safeEntrypoint The SafeEntrypoint contract address
   */
  function createSafeEntrypoint(
    address _safe,
    uint256 _shortTxExecutionDelay,
    uint256 _longTxExecutionDelay,
    uint256 _txExpiryDelay
  ) external returns (address _safeEntrypoint);

  // ~~~ STORAGE METHODS ~~~

  /**
   * @notice Gets the MultiSendCallOnly contract
   * @return _multiSendCallOnly The MultiSendCallOnly contract address
   */
  function MULTI_SEND_CALL_ONLY() external view returns (address _multiSendCallOnly);
}
