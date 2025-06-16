// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';

/**
 * @title IOPxAction
 * @notice Interface for the OPxAction contract
 */
interface IOPxAction is IActionsBuilder {
  /**
   * @notice Returns the OPX contract address
   * @return _opx The OPX contract address
   */
  function OPX() external view returns (address _opx);

  /**
   * @notice Returns the SAFE contract address
   * @return _safe The SAFE contract address
   */
  function SAFE() external view returns (address _safe);
}
