// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./IAction.sol";

interface ITrigger {
    struct Trigger {
        string triggerType;
        string phase;
        string title;
        string source;
        string riverBasin;
        string paramsHash;
        bool isMandatory;
        bool isTriggered;
        address actionContract;   // optional: contract to call when triggered
    }

    /// @notice Register a new trigger configuration
    /// @param trigger Trigger details
    /// @return triggerId Unique ID assigned to this trigger
    function registerTrigger(Trigger calldata trigger) external returns (uint256 triggerId);

    /// @notice Update trigger phase and status (optional backend call)
    function updateTrigger(
        uint256 triggerId,
        string calldata newPhase,
        bool newTriggered
    ) external;

    /// @notice Set a trigger to triggered and optionally execute action contract
    /// @param triggerId ID of the trigger
    /// @param params Optional parameters passed to action contract
    function setTriggered(uint256 triggerId, bytes calldata params) external;

    /// @notice Fetch details of a trigger
    function getTrigger(uint256 triggerId) external view returns (Trigger memory);

    /* ========== EVENTS ========== */
    event TriggerRegistered(uint256 indexed triggerId, string title, string source, address actionContract);
    event TriggerUpdated(uint256 indexed triggerId, string newPhase, bool newTriggered);
    event TriggerExecuted(uint256 indexed triggerId, address actionContract, bytes params);
}
