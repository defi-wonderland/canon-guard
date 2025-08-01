// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

// Simplified mocks for external contracts used in Everclear and OPx actions

contract MockxERC20Lockbox {
  IERC20 public immutable erc20;
  IERC20 public immutable xERC20;

  constructor(address _erc20, address _xERC20) {
    erc20 = IERC20(_erc20);
    xERC20 = IERC20(_xERC20);
  }

  function deposit(uint256 _amount) external {
    erc20.transferFrom(msg.sender, address(this), _amount);
    // Mint xERC20 tokens (simplified)
  }
}

contract MockVestingEscrow {
  function unclaimed() external pure returns (uint256) {
    return 1000;
  }
}

contract MockVestingWallet {
  function claim(address) external pure {
    // Mock claim function
  }

  function release() external pure {
    // Mock release function
  }

  function vestedAmount(uint64) external pure returns (uint256) {
    return 2000;
  }

  function released() external pure returns (uint256) {
    return 500;
  }
}

contract MockGateway {
  function quoteMessage(uint32, bytes calldata, uint256) external pure returns (uint256) {
    return 0.1 ether; // Mock gas fee
  }
}

contract MockSpokeBridge {
  uint32 public constant EVERCLEAR_ID = 1;
  address public gateway;

  constructor(address _gateway) {
    gateway = _gateway;
  }

  function increaseLockPosition(uint128, uint128, uint256) external payable {
    // Mock increase lock position
  }
}

contract MockOPx {
  mapping(address => uint256) private _balances;

  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function mint(address to, uint256 amount) external {
    _balances[to] += amount;
  }

  function downgrade(uint256) external pure {
    // Mock downgrade function
  }
}
