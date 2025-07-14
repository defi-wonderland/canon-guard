// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {AddOwnerWithThresholdAction} from 'contracts/actions-builders/AddOwnerWithThresholdAction.sol';
import {IAddOwnerWithThresholdActionFactory} from 'interfaces/factories/IAddOwnerWithThresholdActionFactory.sol';

/**
 * @title AddOwnerWithThresholdActionFactory
 * @notice Contract that deploys AddOwnerWithThresholdAction contracts
 */
contract AddOwnerWithThresholdActionFactory is IAddOwnerWithThresholdActionFactory {
  // ~~~ FACTORY METHODS ~~~

  /// @inheritdoc IAddOwnerWithThresholdActionFactory
  function createAddOwnerWithThresholdAction(
    address _safe,
    address _newOwner,
    bool _increaseThreshold
  ) external returns (address _addOwnerWithThresholdAction) {
    _addOwnerWithThresholdAction = address(new AddOwnerWithThresholdAction(_safe, _newOwner, _increaseThreshold));
  }
}
