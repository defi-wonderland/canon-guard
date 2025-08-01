/// "Global" mock for all call target of the safe

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

contract ActionTarget is IERC20 {
  bool public isDeposited;
  bool public isTransferred;

  function deposit() public payable {
    isDeposited = true;
  }

  function transfer(address _to, uint256 _amount) public override returns (bool) {
    isTransferred = true;
    return true;
  }

  function reset() public {
    isDeposited = false;
    isTransferred = false;
  }

  // ERC20 Implementation
  function name() public pure returns (string memory) {
    return 'ActionTarget';
  }

  function symbol() public pure returns (string memory) {
    return 'AT';
  }

  function decimals() public pure returns (uint8) {
    return 18;
  }

  function totalSupply() public view override returns (uint256) {
    return 1;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return 1;
  }

  function allowance(address owner, address spender) public view override returns (uint256) {
    return 1;
  }

  function approve(address spender, uint256 amount) public override returns (bool) {
    return true;
  }

  function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
    return true;
  }

  function mint(address to, uint256 amount) public {}
}
