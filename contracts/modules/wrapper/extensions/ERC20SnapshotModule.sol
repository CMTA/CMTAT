//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../security/AuthorizationModule.sol";
import "../../internal/ERC20SnapshotModuleInternal.sol";

/**
 * @dev Snapshot module.
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 */

abstract contract ERC20SnapshotModule is
    ERC20SnapshotModuleInternal,
    AuthorizationModule
{
    /* ============ State Variables ============ */
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");
    /* ============  Initializer Function ============ */
    function __ERC20SnasphotModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /** 
    * @notice 
    * Schedule a snapshot at the given time specified as a number of seconds since epoch.
    * The time cannot be before the time of the latest scheduled, but not yet created snapshot.  
    */
    function scheduleSnapshot(uint256 time) public onlyRole(SNAPSHOOTER_ROLE) {
        _scheduleSnapshot(time);
    }

    /** 
    * @notice 
    * Schedule a snapshot at the given time specified as a number of seconds since epoch.
    * The time cannot be before the time of the latest scheduled, but not yet created snapshot.  
    */
    function scheduleSnapshotNotOptimized(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _scheduleSnapshotNotOptimized(time);
    }

    /** 
    * @notice
    * Reschedule the scheduled snapshot, but not yet created snapshot with the given oldTime to be created at the given newTime specified as a number of seconds since epoch. 
    * The newTime cannot be before the time of the previous scheduled, but not yet created snapshot, or after the time fo the next scheduled snapshot. 
    */
    function rescheduleSnapshot(
        uint256 oldTime,
        uint256 newTime
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _rescheduleSnapshot(oldTime, newTime);
    }

    /**
    * @notice 
    * Cancel creation of the scheduled snapshot, but not yet created snapshot with the given time. 
    * There should not be any other snapshots scheduled after this one. 
    */
    function unscheduleLastSnapshot(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _unscheduleLastSnapshot(time);
    }

    /** 
    * @notice 
    * Cancel creation of the scheduled snapshot, but not yet created snapshot with the given time. 
    */
    function unscheduleSnapshotNotOptimized(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _unscheduleSnapshotNotOptimized(time);
    }
}
