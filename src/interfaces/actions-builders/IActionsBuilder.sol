// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/**
 * @title IActionsBuilder
 * @notice Interface for an ActionsBuilder contract
 */
interface IActionsBuilder {
  // ~~~ STRUCTS ~~~

  /**
   * @notice Struct for a transaction action
   * @param target The target address of the action (e.g., WETH)
   * @param data The data of the action (i.e., abi.encodeCall(function, (args)))
   * @param value The value of the action (i.e., msg.value)
   */
  struct Action {
    address target;
    bytes data;
    uint256 value;
  }

  // ~~~ ERRORS ~~~

  /**
   * @notice Thrown when the data is invalid
   */
  error InvalidData();

  // ~~~ ACTIONS METHODS ~~~

  /**
   * @notice Gets the list of transaction actions
   * @return _actions The array of actions
   */
  function getActions(bytes memory _data) external view returns (Action[] memory _actions);
}
