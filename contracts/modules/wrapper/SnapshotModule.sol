//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "./AuthorizationModule.sol";
import "../internal/SnapshotModuleInternal.sol";

/**
 * @dev Snapshot module.
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 */
abstract contract SnasphotModule is SnapshotModuleInternal, AuthorizationModule {
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");

    function scheduleSnapshot(uint256 time)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _scheduleSnapshot(time);
    }

    function rescheduleSnapshot(uint256 oldTime, uint256 newTime)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _rescheduleSnapshot(oldTime, newTime);
    }

    function unscheduleSnapshot(uint256 time)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _unscheduleSnapshot(time);
    }
}
