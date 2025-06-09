// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface ISpokeBridge {
  function increaseLockPosition(uint128 _additionalAmountToLock, uint128 _expiry, uint256 _gasLimit) external;
}
