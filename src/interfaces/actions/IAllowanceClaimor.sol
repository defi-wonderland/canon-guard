// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IActionsBuilder} from 'interfaces/actions/IActionsBuilder.sol';

/**
 * @title IAllowanceClaimor
 * @notice Interface for the AllowanceClaimor contract
 */
interface IAllowanceClaimor is IActionsBuilder {
  // ~~~ STORAGE METHODS ~~~

  /**
   * @notice Gets the Safe contract
   * @return _safe The Gnosis Safe contract address
   */
  function SAFE() external view returns (address _safe);

  /**
   * @notice Gets the token contract
   * @return _token The token contract address
   */
  function TOKEN() external view returns (address _token);

  /**
   * @notice Gets the token owner
   * @return _tokenOwner The token owner address
   */
  function TOKEN_OWNER() external view returns (address _tokenOwner);

  /**
   * @notice Gets the token recipient
   * @return _tokenRecipient The token recipient address
   */
  function TOKEN_RECIPIENT() external view returns (address _tokenRecipient);
}
