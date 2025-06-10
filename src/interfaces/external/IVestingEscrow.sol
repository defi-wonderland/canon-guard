// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IVestingEscrow {
  function unclaimed() external view returns (uint256 _amount);
}
