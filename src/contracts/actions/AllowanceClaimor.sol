// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IAllowanceClaimor} from 'interfaces/actions/IAllowanceClaimor.sol';

import {IERC20} from 'forge-std/interfaces/IERC20.sol';

contract AllowanceClaimor is IAllowanceClaimor {
  address public immutable SAFE;
  address public immutable TOKEN;
  address public immutable TOKEN_OWNER;
  address public immutable TOKEN_RECIPIENT;

  constructor(address _safe, address _token, address _tokenOwner, address _tokenRecipient) {
    SAFE = _safe;
    TOKEN = _token;
    TOKEN_OWNER = _tokenOwner;
    TOKEN_RECIPIENT = _tokenRecipient;
  }

  function getActions() external view returns (Action[] memory _actions) {
    uint256 _amountToClaim = IERC20(TOKEN).allowance(TOKEN_OWNER, SAFE);
    uint256 _balance = IERC20(TOKEN).balanceOf(TOKEN_OWNER);
    if (_amountToClaim > _balance) {
      _amountToClaim = _balance;
    }

    _actions = new Action[](1);
    _actions[0] = Action({
      target: TOKEN,
      data: abi.encodeCall(IERC20.transferFrom, (TOKEN_OWNER, TOKEN_RECIPIENT, _amountToClaim)),
      value: 0
    });
  }
}
