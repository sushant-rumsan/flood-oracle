// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title TriggerContract
 * @notice Generic Trigger contract for indicators like rainfall, discharge, water level, etc.
 * @dev Reflects your TypeScript Indicator and Location structures.
 */
contract TriggerContract {
    enum IndicatorType {
        WATER_LEVEL_M,
        DISCHARGE_M3S,
        RAINFALL_MM,
        PROB_FLOOD
    }

    enum IndicatorKind {
        OBSERVATION,
        FORECAST
    }

    enum LocationKind {
        STATION,
        BASIN,
        POINT
    }

    struct Source {
        string key;
        string metadata;
    }

    struct Location {
        LocationKind kind;
        uint256 seriesId;
        string basinId;
        int256 lat;
        int256 lon;
    }

    struct Indicator {
        IndicatorKind kind;
        IndicatorType indicator;
        uint256 value;
        string units;
        string issuedAt;
        Location location;
        Source source;
        uint256 confidence;
    }

    struct Trigger {
        uint256 id;
        Indicator indicator;
        bool isTriggered;
    }

    mapping(uint256 => Trigger) public triggers;
    uint256 public triggerCount;

    event TriggerAdded(uint256 indexed id, IndicatorType indicator, uint256 value, string issuedAt);
    event TriggerUpdated(uint256 indexed id, bool isTriggered);

    /**
     * @notice Add a new trigger with indicator details
     * @param indicator The indicator data
     */
    function addTrigger(Indicator calldata indicator) external returns (uint256) {
        uint256 id = ++triggerCount;

        triggers[id] = Trigger({
            id: id,
            indicator: indicator,
            isTriggered: false
        });

        emit TriggerAdded(id, indicator.indicator, indicator.value, indicator.issuedAt);
        return id;
    }

    /**
     * @notice Update a trigger to mark it as triggered
     * @param id The trigger ID
     * @param status true = triggered, false = not triggered
     */
    function updateTriggerStatus(uint256 id, bool status) external {
        require(id > 0 && id <= triggerCount, "Invalid trigger ID");
        triggers[id].isTriggered = status;
        emit TriggerUpdated(id, status);
    }

    /**
     * @notice Get trigger details
     */
    function getTrigger(uint256 id) external view returns (Trigger memory) {
        require(id > 0 && id <= triggerCount, "Invalid trigger ID");
        return triggers[id];
    }
}
