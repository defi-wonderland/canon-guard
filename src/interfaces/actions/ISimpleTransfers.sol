// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions/IActionsBuilder.sol';

interface ISimpleTransfers is IActionsBuilder {
  // ~~~ STRUCTS ~~~

  struct Transfer {
    address token;
    address to;
    uint256 amount;
  }

  // ~~~ EVENTS ~~~

  event SimpleTransferAdded(address indexed _token, address indexed _to, uint256 _amount);
}
