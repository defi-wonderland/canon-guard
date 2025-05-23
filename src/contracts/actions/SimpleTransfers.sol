// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISimpleTransfers} from 'interfaces/actions/ISimpleTransfers.sol';

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

contract SimpleTransfers is ISimpleTransfers {
  Action[] internal _actions;

  constructor(Transfer[] memory _transfers) {
    uint256 _transfersLength = _transfers.length;
    Transfer memory _transfer;
    Action memory _action;

    for (uint256 _i; _i < _transfersLength; ++_i) {
      _transfer = _transfers[_i];

      _action = Action({
        target: _transfer.token,
        data: abi.encodeCall(IERC20.transfer, (_transfer.to, _transfer.amount)),
        value: 0
      });

      _actions.push(_action);
      emit SimpleTransferAdded(_transfer.token, _transfer.to, _transfer.amount);
    }
  }

  function getActions() external view returns (Action[] memory) {
    return _actions;
  }
}
