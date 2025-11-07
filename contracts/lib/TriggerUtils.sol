// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./TriggerLib.sol";

/// @title Trigger Utilities
/// @notice Provides reusable functions for condition evaluation based on minimal Condition struct
library TriggerUtils {

    /// @notice Evaluates whether a given observed value satisfies the condition
    /// @param observedValue The value observed at trigger time
    /// @param condition The condition to evaluate against (threshold + operator)
    /// @return True if the condition is satisfied
    function evaluate(uint256 observedValue, TriggerLib.Condition memory condition)
        internal
        pure
        returns (bool)
    {
        string memory op = condition.operator;
        uint256 threshold = condition.value;

        // Comparison operators
        if (compareStrings(op, ">")) return observedValue > threshold;
        if (compareStrings(op, ">=")) return observedValue >= threshold;
        if (compareStrings(op, "<")) return observedValue < threshold;
        if (compareStrings(op, "<=")) return observedValue <= threshold;
        if (compareStrings(op, "==")) return observedValue == threshold;
        if (compareStrings(op, "!=")) return observedValue != threshold;

        revert("TriggerUtils: invalid operator");
    }

    /// @notice Compares two strings for equality
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
