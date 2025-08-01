/// "Global" mock for all call target of the safe

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

contract ActionTarget is IERC20 {
  // Original flags
  bool public isDeposited;
  bool public isTransferred;

  // External contract function flags and arguments
  bool public isClaimed;
  address public claimArg;

  bool public isReleased;

  bool public isApproved;
  address public approveSpender;
  uint256 public approveAmount;

  bool public isERC20Deposited;
  uint256 public depositAmount;

  bool public isDowngraded;
  uint256 public downgradeAmount;

  bool public isUpdateStateCalled;
  bytes public updateStateData;

  bool public isIncreaseLockPositionCalled;
  uint128 public lockPositionAmount;
  uint128 public lockTime;
  uint256 public gasLimit;

  bool public isTransferFromCalled;
  address public transferFromSender;
  address public transferFromRecipient;
  uint256 public transferFromAmount;

  // Vesting/External functions
  uint256 public constant UNCLAIMED_AMOUNT = 1000;
  uint256 public constant VESTED_AMOUNT = 2000;
  uint256 public constant RELEASED_AMOUNT = 500;
  uint256 public constant QUOTE_MESSAGE_FEE = 0.1 ether;
  uint32 public constant EVERCLEAR_ID = 1;

  function deposit() public payable {
    isDeposited = true;
  }

  function transfer(address _to, uint256 _amount) public override returns (bool) {
    isTransferred = true;
    return true;
  }

  // External contract functions with flags
  function claim(address _vestingEscrow) external {
    isClaimed = true;
    claimArg = _vestingEscrow;
  }

  function release() external {
    isReleased = true;
  }

  function approve(address _spender, uint256 _amount) public override returns (bool) {
    isApproved = true;
    approveSpender = _spender;
    approveAmount = _amount;
    return true;
  }

  function deposit(uint256 _amount) external {
    isERC20Deposited = true;
    depositAmount = _amount;
  }

  function downgrade(uint256 _amount) external {
    isDowngraded = true;
    downgradeAmount = _amount;
  }

  function updateState(bytes calldata _data) external {
    isUpdateStateCalled = true;
    updateStateData = _data;
  }

  function increaseLockPosition(uint128 _amount, uint128 _lockTime, uint256 _gasLimit) external payable {
    isIncreaseLockPositionCalled = true;
    lockPositionAmount = _amount;
    lockTime = _lockTime;
    gasLimit = _gasLimit;
  }

  // Additional required external view functions
  function unclaimed() external pure returns (uint256) {
    return UNCLAIMED_AMOUNT;
  }

  function vestedAmount(uint64) external pure returns (uint256) {
    return VESTED_AMOUNT;
  }

  function released() external pure returns (uint256) {
    return RELEASED_AMOUNT;
  }

  function quoteMessage(uint32, bytes calldata, uint256) external pure returns (uint256) {
    return QUOTE_MESSAGE_FEE;
  }

  function gateway() external view returns (address) {
    return address(this);
  }

  function reset() public {
    // Reset original flags
    isDeposited = false;
    isTransferred = false;

    // Reset external function flags
    isClaimed = false;
    claimArg = address(0);
    isReleased = false;
    isApproved = false;
    approveSpender = address(0);
    approveAmount = 0;
    isERC20Deposited = false;
    depositAmount = 0;
    isDowngraded = false;
    downgradeAmount = 0;
    isUpdateStateCalled = false;
    updateStateData = '';
    isIncreaseLockPositionCalled = false;
    lockPositionAmount = 0;
    lockTime = 0;
    gasLimit = 0;
    isTransferFromCalled = false;
    transferFromSender = address(0);
    transferFromRecipient = address(0);
    transferFromAmount = 0;
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

  function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
    isTransferFromCalled = true;
    transferFromSender = from;
    transferFromRecipient = to;
    transferFromAmount = amount;
    return true;
  }

  function mint(address to, uint256 amount) public {}
}
