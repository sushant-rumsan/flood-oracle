// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "../lib/TriggerLib.sol";

interface ITrigger {

    struct Trigger {
        uint256 id;
        TriggerLib.Condition condition;
        bool isTriggered;
    }

    /// @notice Add a new trigger
    function addTrigger(TriggerLib.Condition calldata condition) external returns (uint256 triggerId);

    /// @notice Set a trigger as triggered
    function setTrigger(uint256 triggerId, uint256 observedValue) external;

    /// @notice Get a trigger
    function getTrigger(uint256 triggerId) external view returns (Trigger memory);

    /// @notice Get the observed value for a trigger
    function getTriggerValue(uint256 triggerId) external view returns (uint256);

    /// @notice Total number of triggers
    function totalTriggers() external view returns (uint256);

    /* ========== EVENTS ========== */
    event TriggerAdded(uint256 indexed triggerId, TriggerLib.Condition condition);
    event TriggerActivated(uint256 indexed triggerId, uint256 value);
}
