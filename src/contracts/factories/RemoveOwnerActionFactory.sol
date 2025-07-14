// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {RemoveOwnerAction} from 'contracts/actions-builders/RemoveOwnerAction.sol';
import {IRemoveOwnerActionFactory} from 'interfaces/factories/IRemoveOwnerActionFactory.sol';

/**
 * @title RemoveOwnerActionFactory
 * @notice Contract that deploys RemoveOwnerAction contracts
 */
contract RemoveOwnerActionFactory is IRemoveOwnerActionFactory {
  // ~~~ FACTORY METHODS ~~~

  /// @inheritdoc IRemoveOwnerActionFactory
  function createRemoveOwnerAction(
    address _safe,
    address _ownerToRemove,
    bool _decreaseThreshold
  ) external returns (address _removeOwnerAction) {
    _removeOwnerAction = address(new RemoveOwnerAction(_safe, _ownerToRemove, _decreaseThreshold));
  }
}
