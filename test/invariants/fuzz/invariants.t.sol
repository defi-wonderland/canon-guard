// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Setup} from './Setup.t.sol';

contract Invariants is Setup {
  function invariant_testSanity() public {
    assertEq(handlersTarget.safe().VERSION(), '1.5.0');
  }

  function test_simpleActions() public {
    handlersTarget.handler_queueSimpleAction(1000);

    handlersTarget.handler_approveHash(0, 0);
    handlersTarget.handler_approveHash(1, 0);
    handlersTarget.handler_approveHash(2, 0);
    handlersTarget.handler_approveHash(3, 0);
    handlersTarget.handler_approveHash(4, 0);

    vm.warp(block.timestamp + LONG_TX_EXECUTION_DELAY + 1000);

    handlersTarget.handler_executeTransaction_SimpleActions(0); // assert then reset in this handler
  }
}
