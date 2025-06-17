// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {SafeManageable} from 'contracts/SafeManageable.sol';

/**
 * @title EmergencyModeHook
 * @notice Hook that allows for the execution of transactions in emergency mode
 */
// solhint-disable-next-line payable-fallback
abstract contract EmergencyModeHook is SafeManageable {
  // ~~~ STORAGE ~~~

  bool public emergencyMode;
  address public emergencyCaller;
  address public emergencyTrigger;

  // ~~~ ERRORS ~~~

  error EmergencyModeHook__Unauthorized(address _sender);

  // ~~~ ADMIN METHODS ~~~

  function setEmergencyMode(bool _emergencyMode) external {
    if (msg.sender != emergencyTrigger) revert EmergencyModeHook__Unauthorized(msg.sender);
    emergencyMode = _emergencyMode;
  }

  function setEmergencyCaller(address _emergencyCaller) external isSafe {
    emergencyCaller = _emergencyCaller;
  }

  function setEmergencyTrigger(address _emergencyTrigger) external isSafe {
    emergencyTrigger = _emergencyTrigger;
  }

  // ~~~ GETTER METHODS ~~~

  function _onBeforeExecution() internal virtual {
    if (emergencyMode && msg.sender != emergencyCaller) revert EmergencyModeHook__Unauthorized(msg.sender);
  }
}
