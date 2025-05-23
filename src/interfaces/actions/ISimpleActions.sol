// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions/IActionsBuilder.sol';

interface ISimpleActions is IActionsBuilder {
  // ~~~ STRUCTS ~~~

  struct SimpleAction {
    address target; // e.g. WETH
    string signature; // e.g. "transfer(address,uint256)"
    bytes data; // e.g. abi.encode(address,uint256)
    uint256 value; // (msg.value)
  }

  // ~~~ EVENTS ~~~

  event SimpleActionAdded(address indexed _target, string _signature, bytes _data, uint256 _value);
}
