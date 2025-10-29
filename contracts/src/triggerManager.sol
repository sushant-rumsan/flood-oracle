// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "../interface/IAction.sol";
import "../interface/ITrigger.sol";

/**
 * @title Trigger
 * @dev Manages trigger configurations with role-based access control.
 *      Uses OpenZeppelin AccessControl for secure permissions management.
 */
contract Trigger is ITrigger, AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant TRIGGER_EXECUTOR_ROLE = keccak256("TRIGGER_EXECUTOR_ROLE");

    uint256 private triggerCounter;

    struct TriggerStorage {
        string triggerType;
        string phase;
        string title;
        string source;
        string riverBasin;
        string paramsHash;
        bool isMandatory;
        bool isTriggered;
        address actionContract;
        bool exists;
    }

    mapping(uint256 => TriggerStorage) private _triggers;

    event TriggerExecutionFailed(uint256 indexed triggerId, address actionContract, bytes params, string reason);

    constructor() {
        address deployer = msg.sender;
        _grantRole(ADMIN_ROLE, deployer);
        _grantRole(TRIGGER_EXECUTOR_ROLE, deployer);
        
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(TRIGGER_EXECUTOR_ROLE, ADMIN_ROLE);
    }

    /// @notice Register a new trigger configuration
    /// @dev Admin only. Returns assigned triggerId.
    function registerTrigger(Trigger calldata trigger) external onlyRole(ADMIN_ROLE) returns (uint256 triggerId) {
        triggerId = triggerCounter++;
        require(!_triggers[triggerId].exists, "Id already exists");

        _triggers[triggerId] = TriggerStorage({
            triggerType: trigger.triggerType,
            phase: trigger.phase,
            title: trigger.title,
            source: trigger.source,
            riverBasin: trigger.riverBasin,
            paramsHash: trigger.paramsHash,
            isMandatory: trigger.isMandatory,
            isTriggered: trigger.isTriggered,
            actionContract: trigger.actionContract,
            exists: true
        });

        emit TriggerRegistered(triggerId, trigger.title, trigger.source, trigger.actionContract);
        return triggerId;
    }

    /// @notice Update trigger phase and status
    /// @dev Admin only
    function updateTrigger(
        uint256 triggerId,
        string calldata newPhase,
        bool newTriggered
    ) external onlyRole(ADMIN_ROLE) {
        require(_triggers[triggerId].exists, "Trigger not found");

        _triggers[triggerId].phase = newPhase;
        _triggers[triggerId].isTriggered = newTriggered;

        emit TriggerUpdated(triggerId, newPhase, newTriggered);
    }

    /// @notice Set a trigger to triggered and optionally execute action contract
    /// @dev Trigger executor or admin only. If actionContract is present it will be called.
    function setTriggered(uint256 triggerId, bytes calldata params) external onlyRole(TRIGGER_EXECUTOR_ROLE) {
        require(_triggers[triggerId].exists, "Trigger not found");

        _triggers[triggerId].isTriggered = true;

        emit TriggerUpdated(triggerId, _triggers[triggerId].phase, true);

        address actionAddr = _triggers[triggerId].actionContract;
        if (actionAddr != address(0)) {
            // Attempt to call the action. Do not revert trigger update on failure.
            try IAction(actionAddr).executeAction(triggerId, params) {
                emit TriggerExecuted(triggerId, actionAddr, params);
            } catch Error(string memory reason) {
                emit TriggerExecutionFailed(triggerId, actionAddr, params, reason);
            } catch {
                emit TriggerExecutionFailed(triggerId, actionAddr, params, "execution failed");
            }
        } else {
            // No action contract configured
            emit TriggerExecuted(triggerId, address(0), params);
        }
    }

    /// @notice Fetch details of a trigger
    function getTrigger(uint256 triggerId) external view returns (Trigger memory) {
        require(_triggers[triggerId].exists, "trigger not found");
        TriggerStorage storage s = _triggers[triggerId];

        Trigger memory out = Trigger({
            triggerType: s.triggerType,
            phase: s.phase,
            title: s.title,
            source: s.source,
            riverBasin: s.riverBasin,
            paramsHash: s.paramsHash,
            isMandatory: s.isMandatory,
            isTriggered: s.isTriggered,
            actionContract: s.actionContract
        });

        return out;
    }

    /// @notice Update action contract for an existing trigger
    /// @dev Admin only
    function setTriggerActionContract(uint256 triggerId, address actionContract) external onlyRole(ADMIN_ROLE) {
        require(_triggers[triggerId].exists, "trigger not found");
        _triggers[triggerId].actionContract = actionContract;
    }

    function grantRole(bytes32 role, address account) 
        public 
        override 
        onlyRole(getRoleAdmin(role)) 
    {
        require(account != address(0), "Account cannot be zero address");
        super.grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) 
        public 
        override 
        onlyRole(getRoleAdmin(role)) 
    {
        require(account != address(0), "Account cannot be zero address");
        super.revokeRole(role, account);
    }
}
