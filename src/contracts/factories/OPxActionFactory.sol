// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {OPxAction} from 'contracts/actions-builders/OPxAction.sol';
import {IOPxActionFactory} from 'interfaces/factories/IOPxActionFactory.sol';

/**
 * @title OPxActionFactory
 * @notice Contract that deploys OPxAction contracts
 */
contract OPxActionFactory is IOPxActionFactory {
  // ~~~ FACTORY METHODS ~~~

  /// @inheritdoc IOPxActionFactory
  function createOPxAction(address _opx, address _safe) external returns (address _opxAction) {
    _opxAction = address(new OPxAction(_opx, _safe));
  }
}
