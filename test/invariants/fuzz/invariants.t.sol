// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Setup} from './Setup.t.sol';

contract Invariants is Setup {
  function invariant_testSanity() public {
    handlersEntryPoint.handler_changeMaxApprovalDuration(1000);
    assertEq(_safe.VERSION(), '1.5.0');
  }
}
