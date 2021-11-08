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
The function returns the `time` (as an ID) at which the new snapshot is scheduled.
Only authorized users are allowed to call this function.

#### `rescheduleSnapshot(uint,uint)`

##### Signature:

```solidity
    function rescheduleSnapshot (uint oldTime, uint newTime)
    public returns (uint)
```

#### Description:

Reschedule the scheduled, but not yet created snapshot with the given `oldTime` to be created at the given `newTime` specified as a number of seconds since epoch.
The `newTime` cannot be before the time of the previous scheduled, but not yet created snapshot, or after the time fo the next scheduled snapshot.
The function returns the original `time` the snapshot was scheduled at.
Only authorized users are allowed to call this function.

#### `unscheduleSnapshot(uint)`

##### Signature:

```solidity
    function unscheduleSnapshot (uint time)
    public returns (uint)
```

##### Description:

Cancel creation of the scheduled, but not yet created snapshot with the given `time`.
There should not be any other snapshots scheduled after this one.
The function returns the original `time` the snapshot was scheduled at.
Only authorized users are allowed to call this function.

#### `snapshotTotalSupply(uint)`

##### Signature:

```solidity
    function snapshotTotalSupply (uint time)
    public view returns (uint)
```

##### Description:

Return the total number of token in circulation at the time when the snapshot with the given `time` was created.

#### `snapshotBalanceOf(uint,address)`

##### Signature:

```solidity
    function snapshotBalanceOf (uint time, address owner)
    public view returns (uint)
```

##### Description:

Return the number of tokens owned by the given `owner` at the time when the snapshot with the given `time` was created.

### Events

#### `SnapshotSchedule(uint,uint)`

##### Signature:

```solidity
    event SnapshotSchedule (uint indexed oldTime, uint indexed newTime)
```

##### Description:

Emitted when the snapshot with the specified `oldTime` was scheduled or rescheduled at the specified `newTime`.

#### `SnapshotUnscheduling(uint)`

##### Signature:

```solidity
    event SnapshotUnschedule (uint indexed time)
```

##### Description:

Emitted when the scheduled snapshot with the specified `time` was cancelled.
