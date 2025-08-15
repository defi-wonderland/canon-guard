// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {ISafeEntrypoint} from 'interfaces/ISafeEntrypoint.sol';
import {IActionsBuilder} from 'interfaces/actions-builders/IActionsBuilder.sol';
import {IApproveAction} from 'interfaces/actions-builders/IApproveAction.sol';

contract ApproveAction is IApproveAction {
  /// @inheritdoc IApproveAction
  address public immutable SAFE_ENTRYPOINT;

  /// @inheritdoc IApproveAction
  address public immutable ACTIONS_BUILDER;

  /// @inheritdoc IApproveAction
  uint256 public immutable APPROVAL_DURATION;

  /**
   * @notice Constructor that sets up the ApproveAction contract
   * @param _safeEntrypoint The SafeEntrypoint contract address
   * @param _actionsBuilder The actions builder contract address
   * @param _approvalDuration The approval duration
   */
  constructor(address _safeEntrypoint, address _actionsBuilder, uint256 _approvalDuration) {
    SAFE_ENTRYPOINT = _safeEntrypoint;
    ACTIONS_BUILDER = _actionsBuilder;
    APPROVAL_DURATION = _approvalDuration;
  }

  // ~~~ ACTIONS METHODS ~~~

  /// @inheritdoc IActionsBuilder
  function getActions() external view returns (Action[] memory _actions) {
    _actions = new Action[](1);
    _actions[0] = Action({
      target: SAFE_ENTRYPOINT,
      data: abi.encodeCall(ISafeEntrypoint.approveActionsBuilderOrHub, (ACTIONS_BUILDER, APPROVAL_DURATION)),
      value: 0
    });
  }
}
