# Snapshot Module

This document defines the Snapshot Module for the CMTA Token specification.


## API for Ethereum

This section describes the Ethereum API of the Snapshot Module.

### Functions

#### `scheduleSnapshot(uint)`

##### Signature:

```solidity
    function scheduleSnapshot (uint time)
    public returns (uint)
```

##### Description:

Schedule a snapshot at the given `time` specified as a number of seconds since epoch.
The `time` cannot be before the time of the latest scheduled, but not yet created snapshot.
The function returns the ID of the new snapshot.
Only authorized users are allowed to call this function.

#### `rescheduleSnapshot(uint,uint)`

##### Signature:

```solidity
    function rescheduleSnapshot (uint snapshotID, uint newTime)
    public returns (uint)
```

#### Description:

Reschedule the scheduled, but not yet created snapshot with the given `snapshotID` to be created at the given `newTime` specified as a number of seconds since epoch.
The `newTime` cannot be before the time of the previous scheduled, but not yet created snapshot, or after the time fo the next scheduled snapshot.
The function returns the original `time` the snapshot was scheduled at.
Only authorized users are allowed to call this function.

#### `unscheduleSnapshot(uint)`

##### Signature:

```solidity
    function unscheduleSnapshot (uint snapshotID)
    public returns (uint)
```

##### Description:

Cancel creation of the scheduled, but not yet created snapshot with the given `snapshotID`.
There should be not other snapshots scheduled after this one.
The function returns the original `time` the snapshot was scheduled at.
Only authorized users are allowed to call this function.

#### `snapshotTime(uint)`

##### Signature:

```solidity
    function snapshotTime (uint snapshotID)
    public view returns (uint)
```

##### Description:

Return the time for the scheduled, but not yet executed snapshot with the given `snapshotID`.

#### `snapshotTotalSupply(uint)`

##### Signature:

```solidity
    function snapshotTotalSupply (uint snapshotID)
    public view returns (uint)
```

##### Description:

Return the total number of token in circulation at the time when the snapshot with the given `snapshotID` was created.

#### `snapshotBalanceOf(uint,address)`

##### Signature:

```solidity
    function snapshotBalanceOf (uint snapshotID, address owner)
    public view returns (uint)
```

##### Description:

Return the number of tokens owned by the given `owner` at the time when the snapshot with the given `snapshotID` was created.

### Events

#### `SnapshotScheduling(uint,uint)`

##### Signature:

```solidity
    event SnapshotScheduing (uint indexed snapshotID, uint time)
```

##### Description:

Emitted when the snapshot with the specified `snapshotID` was scheduled or rescheduled at the specified `time`.

#### `SnapshotUnscheduling(uint)`

##### Signature:

```solidity
    event SnapshotUnscheduing (uint indexed snapshotID)
```

##### Description:

Emitted when the scheduled snapshot with the specified `snapshotID` was cancelled.
