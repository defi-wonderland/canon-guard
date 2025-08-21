// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {SimpleActions} from 'contracts/actions-builders/SimpleActions.sol';

import {ISimpleActions} from 'interfaces/actions-builders/ISimpleActions.sol';
import {ISimpleActionsFactory} from 'interfaces/factories/ISimpleActionsFactory.sol';

/**
 * @title SimpleActionsFactory
 * @notice Contract that deploys SimpleActions contracts
 */
contract SimpleActionsFactory is ISimpleActionsFactory {
  // ~~~ FACTORY METHODS ~~~

  /// @inheritdoc ISimpleActionsFactory
  function createSimpleActions(ISimpleActions.SimpleAction[] calldata _simpleActionsArray)
    external
    returns (address _simpleActions)
  {
    _simpleActions = address(new SimpleActions(_simpleActionsArray));
  }

  function createSimpleActions(ISimpleActions.SimpleAction calldata _simpleAction)
    external
    returns (address _simpleActions)
  {
    ISimpleActions.SimpleAction[] memory _simpleActionsArray = new ISimpleActions.SimpleAction[](1);
    _simpleActionsArray[0] = _simpleAction;

    _simpleActions = address(new SimpleActions(_simpleActionsArray));
  }
}
