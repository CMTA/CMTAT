//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../security/AuthorizationModule.sol";
import "../../internal/SnapshotModuleInternal.sol";

/**
 * @dev Snapshot module.
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 */

abstract contract SnapshotModule is
    SnapshotModuleInternal,
    AuthorizationModule
{
    function __SnasphotModule_init(
        string memory name_,
        string memory symbol_,
        address admin
    ) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        // SnapshotModuelInternal inherits from ERC20
        __ERC20_init_unchained(name_, symbol_);
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();

        /* CMTAT modules */
        // Internal
        __Snapshot_init_unchained();

        // Security
        __AuthorizationModule_init_unchained(admin);

        // own function
        __SnasphotModule_init_unchained();
    }

    function __SnasphotModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /*
    @notice 
    Schedule a snapshot at the given time specified as a number of seconds since epoch.
    The time cannot be before the time of the latest scheduled, but not yet created snapshot.  
    */
    function scheduleSnapshot(uint256 time) public onlyRole(SNAPSHOOTER_ROLE) {
        _scheduleSnapshot(time);
    }

    /*
    @notice 
    Schedule a snapshot at the given time specified as a number of seconds since epoch.
    The time cannot be before the time of the latest scheduled, but not yet created snapshot.  
    */
    function scheduleSnapshotNotOptimized(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _scheduleSnapshotNotOptimized(time);
    }

    /* 
    @notice
    Reschedule the scheduled snapshot, but not yet created snapshot with the given oldTime to be created at the given newTime specified as a number of seconds since epoch. 
    The newTime cannot be before the time of the previous scheduled, but not yet created snapshot, or after the time fo the next scheduled snapshot. 
    */
    function rescheduleSnapshot(
        uint256 oldTime,
        uint256 newTime
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _rescheduleSnapshot(oldTime, newTime);
    }

    /*
    @notice 
    Cancel creation of the scheduled snapshot, but not yet created snapshot with the given time. 
    There should not be any other snapshots scheduled after this one. 
    */
    function unscheduleLastSnapshot(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _unscheduleLastSnapshot(time);
    }

    /*
    @notice 
    Cancel creation of the scheduled snapshot, but not yet created snapshot with the given time. 

    */
    function unscheduleSnapshotNotOptimized(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _unscheduleSnapshotNotOptimized(time);
    }

    uint256[50] private __gap;
}
