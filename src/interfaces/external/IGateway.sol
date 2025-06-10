// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IGateway {
  function quoteMessage(
    uint32 _chainId,
    bytes calldata _message,
    uint256 _gasLimit
  ) external view returns (uint256 _fee);
}
