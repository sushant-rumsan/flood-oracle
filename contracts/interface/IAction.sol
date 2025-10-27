// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IAction {
    /// @notice Called by the Trigger contract when a trigger is activated
    /// @param triggerId ID of the trigger that caused this action
    /// @param params Optional parameters passed from the trigger
    function executeAction(uint256 triggerId, bytes calldata params) external;
}
