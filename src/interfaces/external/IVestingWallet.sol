// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IVestingWallet {
  function vestedAmount(uint64 _timestamp) external view returns (uint256 _amount);
  function released() external view returns (uint256 _amount);
  function claim(address _vestingEscrow) external;
}
