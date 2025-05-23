// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISimpleActions} from 'interfaces/actions/ISimpleActions.sol';

contract SimpleActions is ISimpleActions {
  Action[] internal _actions;

  constructor(SimpleAction[] memory _simpleActions) {
    uint256 _simpleActionsLength = _simpleActions.length;
    SimpleAction memory _simpleAction;
    Action memory _action;
    bytes4 _selector;
    bytes memory _completeCallData;

    for (uint256 _i; _i < _simpleActionsLength; ++_i) {
      _simpleAction = _simpleActions[_i];

      _selector = bytes4(keccak256(bytes(_simpleAction.signature)));
      _completeCallData = abi.encodePacked(_selector, _simpleAction.data);

      _action = Action({target: _simpleAction.target, data: _completeCallData, value: _simpleAction.value});

      _actions.push(_action);
      emit SimpleActionAdded(_simpleAction.target, _simpleAction.signature, _simpleAction.data, _simpleAction.value);
    }
  }

  function getActions() external view returns (Action[] memory) {
    return _actions;
  }
}
