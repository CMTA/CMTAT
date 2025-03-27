//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev Snapshot custom errors
*/
library SnapshotErrors {
    // SnapshotModule
    error CMTAT_SnapshotModule_SnapshotScheduledInThePast(
        uint256 time,
        uint256 timestamp
    );
    error CMTAT_SnapshotModule_SnapshotTimestampBeforeLastSnapshot(
        uint256 time,
        uint256 lastSnapshotTimestamp
    );
    error CMTAT_SnapshotModule_SnapshotTimestampAfterNextSnapshot(
        uint256 time,
        uint256 nextSnapshotTimestamp
    );
    error CMTAT_SnapshotModule_SnapshotTimestampBeforePreviousSnapshot(
        uint256 time,
        uint256 previousSnapshotTimestamp
    );
    error CMTAT_SnapshotModule_SnapshotAlreadyExists();
    error CMTAT_SnapshotModule_SnapshotAlreadyDone();
    error CMTAT_SnapshotModule_NoSnapshotScheduled();
    error CMTAT_SnapshotModule_SnapshotNotFound();
}
