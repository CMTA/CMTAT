//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

library Errors {
    error InvalidTransfer(address from, address to, uint256 amount);
    error SnapshotScheduledInThePast(uint256 time, uint256 timestamp);
    error SnapshotTimestampBeforeLastSnapshot(uint256 time, uint256 lastSnapshotTimestamp);
    error SnapshotTimestampAfterNextSnapshot(uint256 time, uint256 nextSnapshotTimestamp);
    error SnapshotTimestampBeforePreviousSnapshot(uint256 time, uint256 previousSnapshotTimestamp);
    error SnapshotAlreadyExists();
    error SnapshotAlreadyDone();
    error SnapshotNotScheduled();
    error SnapshotNotFound();
    error SnapshotNeverScheduled();
    error AddressZeroNotAllowed();
    error DirectCallToImplementation();
    error WrongAllowance(uint256 allowance, uint256 currentAllowance);
    error SameValue();
}
    