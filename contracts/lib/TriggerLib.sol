// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Trigger Library
/// @notice Minimal structures for flood triggers
library TriggerLib {

    struct Condition {
        uint256 value;
        string source;
        string operator;
        string expression;
        string sourceSubType; 
    }

    struct Trigger {
        uint256 id;
        Condition condition;
        bool isTriggered;
    }

    event TriggerAdded(uint256 indexed triggerId, Condition condition);
    event TriggerActivated(uint256 indexed triggerId, uint256 value);
}