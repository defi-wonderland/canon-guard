// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {AllowanceClaimor} from 'contracts/actions/AllowanceClaimor.sol';

import {IAllowanceClaimorFactory} from 'interfaces/factories/IAllowanceClaimorFactory.sol';

/**
 * @title AllowanceClaimorFactory
 * @notice Contract that deploys AllowanceClaimor contracts
 */
contract AllowanceClaimorFactory is IAllowanceClaimorFactory {
  // ~~~ FACTORY METHODS ~~~

  /// @inheritdoc IAllowanceClaimorFactory
  function createAllowanceClaimor(
    address _safe,
    address _token,
    address _tokenOwner,
    address _tokenRecipient
  ) external returns (address _allowanceClaimor) {
    _allowanceClaimor = address(new AllowanceClaimor(_safe, _token, _tokenOwner, _tokenRecipient));
  }
}
