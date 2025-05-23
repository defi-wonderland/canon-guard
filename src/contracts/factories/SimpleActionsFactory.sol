// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {SimpleActions} from 'contracts/actions/SimpleActions.sol';

import {ISimpleActions} from 'interfaces/actions/ISimpleActions.sol';
import {ISimpleActionsFactory} from 'interfaces/factories/ISimpleActionsFactory.sol';

/**
 * @title SimpleActionsFactory
 * @notice Contract that deploys SimpleActions contracts
 */
contract SimpleActionsFactory is ISimpleActionsFactory {
  // ~~~ FACTORY METHODS ~~~

  /// @inheritdoc ISimpleActionsFactory
  function createSimpleActions(ISimpleActions.SimpleAction[] calldata _smplActions)
    external
    returns (address _simpleActions)
  {
    _simpleActions = address(new SimpleActions(_smplActions));
  }
}
