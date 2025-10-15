// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IFloodDataAggregator {
    struct Source {
        string name;
        string description;
        string jsCode;
        uint64 subscriptionId;
        bool active;
    }

    struct SourceData {
        uint256 timestamp;
        string dataUri;
        bytes32 dataHash;
        bytes rawData;
    }

    event SourceRegistered(bytes32 indexed sourceId, string name);
    event SourceDataUpdated(bytes32 indexed sourceId, uint256 timestamp);
    event ChainlinkResponse(bytes32 indexed requestId, bytes response, bytes err);

    function registerSource(
        bytes32 sourceId,
        string calldata name,
        string calldata description,
        string calldata jsCode,
        uint64 subscriptionId
    ) external;

    function sources(bytes32 sourceId) external view returns (
        string memory name,
        string memory description,
        string memory jsCode,
        uint64 subscriptionId,
        bool active
    );

    function requestFloodData(bytes32 sourceId) external returns (bytes32 requestId);

    function lastRequestId() external view returns (bytes32);

    function lastResponse() external view returns (bytes memory);

    function lastError() external view returns (bytes memory);

    function latestData(bytes32 sourceId) external view returns (
        uint256 timestamp,
        string memory dataUri,
        bytes32 dataHash,
        bytes memory rawData
    );
}
