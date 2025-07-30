// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Safe, SafeEntrypoint, SafeEntrypointFactory} from './Setup.t.sol';
import {Test} from 'forge-std/Test.sol';

contract HandlersEntryPoint is Test {
  SafeEntrypoint internal _safeEntrypoint;
  SafeEntrypointFactory internal _safeEntrypointFactory;
  Safe internal _safe;
  address internal _safeOwner;

  constructor(
    SafeEntrypoint __safeEntrypoint,
    SafeEntrypointFactory __safeEntrypointFactory,
    Safe __safe,
    address __safeOwner
  ) {
    _safeEntrypoint = __safeEntrypoint;
    _safeEntrypointFactory = __safeEntrypointFactory;
    _safe = __safe;
    _safeOwner = __safeOwner;
  }

  function handler_changeShortTxDelay(uint256 _shortTxExecutionDelay) public {
    // get current params
    uint256 _longTxExecutionDelay = _safeEntrypoint.LONG_TX_EXECUTION_DELAY();
    uint256 _txExpiryDelay = _safeEntrypoint.TX_EXPIRY_DELAY();
    uint256 _maxApprovalDuration = _safeEntrypoint.MAX_APPROVAL_DURATION();
    address _emergencyTrigger = _safeEntrypoint.emergencyTrigger();
    address _emergencyCaller = _safeEntrypoint.emergencyCaller();

    // redeploy with same params except new delay
    _safeEntrypoint = SafeEntrypoint(
      _safeEntrypointFactory.createSafeEntrypoint(
        address(_safe),
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );

    // set the new entrypoint as guard
    vm.prank(address(_safe));
    _safe.setGuard(address(_safeEntrypoint));
  }

  function handler_changeLongTxDelay(uint256 _longTxExecutionDelay) public {
    // get current params
    uint256 _shortTxExecutionDelay = _safeEntrypoint.SHORT_TX_EXECUTION_DELAY();
    uint256 _txExpiryDelay = _safeEntrypoint.TX_EXPIRY_DELAY();
    uint256 _maxApprovalDuration = _safeEntrypoint.MAX_APPROVAL_DURATION();
    address _emergencyTrigger = _safeEntrypoint.emergencyTrigger();
    address _emergencyCaller = _safeEntrypoint.emergencyCaller();

    // redeploy with same params except new delay
    _safeEntrypoint = SafeEntrypoint(
      _safeEntrypointFactory.createSafeEntrypoint(
        address(_safe),
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );

    // set the new entrypoint as guard
    vm.prank(address(_safe));
    _safe.setGuard(address(_safeEntrypoint));
  }

  function handler_changeTxExpiryDelay(uint256 _txExpiryDelay) public {
    // get current params
    uint256 _shortTxExecutionDelay = _safeEntrypoint.SHORT_TX_EXECUTION_DELAY();
    uint256 _longTxExecutionDelay = _safeEntrypoint.LONG_TX_EXECUTION_DELAY();
    uint256 _maxApprovalDuration = _safeEntrypoint.MAX_APPROVAL_DURATION();
    address _emergencyTrigger = _safeEntrypoint.emergencyTrigger();
    address _emergencyCaller = _safeEntrypoint.emergencyCaller();

    // redeploy with same params except new delay
    _safeEntrypoint = SafeEntrypoint(
      _safeEntrypointFactory.createSafeEntrypoint(
        address(_safe),
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );

    // set the new entrypoint as guard
    vm.prank(address(_safe));
    _safe.setGuard(address(_safeEntrypoint));
  }

  function handler_changeMaxApprovalDuration(uint256 _maxApprovalDuration) public {
    // get current params
    uint256 _shortTxExecutionDelay = _safeEntrypoint.SHORT_TX_EXECUTION_DELAY();
    uint256 _longTxExecutionDelay = _safeEntrypoint.LONG_TX_EXECUTION_DELAY();
    uint256 _txExpiryDelay = _safeEntrypoint.TX_EXPIRY_DELAY();
    address _emergencyTrigger = _safeEntrypoint.emergencyTrigger();
    address _emergencyCaller = _safeEntrypoint.emergencyCaller();

    // redeploy with same params except new delay
    _safeEntrypoint = SafeEntrypoint(
      _safeEntrypointFactory.createSafeEntrypoint(
        address(_safe),
        _shortTxExecutionDelay,
        _longTxExecutionDelay,
        _txExpiryDelay,
        _maxApprovalDuration,
        _emergencyTrigger,
        _emergencyCaller
      )
    );

    // set the new entrypoint as guard
    vm.prank(address(_safe));
    _safe.setGuard(address(_safeEntrypoint));
  }
}
