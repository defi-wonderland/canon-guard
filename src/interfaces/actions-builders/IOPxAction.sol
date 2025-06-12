// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';

/**
 * @title IOPxAction
 * @notice Interface for the OPxAction contract
 */
interface IOPxAction is IActionsBuilder {
  /**
   * @notice Returns the OPx contract address
   * @return _opx The OPx contract address
   */
  function OPx() external view returns (address _opx);
}
