// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../interface/IAction.sol";

contract Action is IAction {
    /// @notice Emitted when executeAction is called
    event ActionExecuted(uint256 indexed triggerId, bytes params, address executor);

    /// @notice Called by the Trigger contract when a trigger is activated
    /// @param triggerId ID of the trigger that caused this action
    /// @param params Optional parameters passed from the trigger
    function executeAction(uint256 triggerId, bytes calldata params) external override {
        emit ActionExecuted(triggerId, params, msg.sender);
    }

}