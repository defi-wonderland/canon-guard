// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IERC20} from 'forge-std/interfaces/IERC20.sol';
import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';
import {ISpokeBridge} from 'interfaces/external/ISpokeBridge.sol';
import {IVestingEscrow} from 'interfaces/external/IVestingEscrow.sol';
import {IVestingWallet} from 'interfaces/external/IVestingWallet.sol';
import {IxERC20Lockbox} from 'interfaces/external/IxERC20Lockbox.sol';

interface IEverclearTokenStake is IActionsBuilder {
  function VESTING_ESCROW() external view returns (IVestingEscrow);
  function VESTING_WALLET() external view returns (IVestingWallet);
  function SPOKE_BRIDGE() external view returns (ISpokeBridge);
  function CLEAR_LOCKBOX() external view returns (IxERC20Lockbox);
  function NEXT() external view returns (IERC20);
  function CLEAR() external view returns (IERC20);
}
