//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Arrays} from '@openzeppelin/contracts/utils/Arrays.sol';

import {SnapshotErrors} from "./SnapshotErrors.sol";

/**
 * @dev Base for the Snapshot module
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 * Inspired by Openzeppelin - ERC20Snapshot but use the time as Id instead of a counter.
 * Contrary to OpenZeppelin, the function _getCurrentSnapshotId is not available 
 *  because overriding this function can break the contract.
 */

abstract contract SnapshotModuleBase is Initializable {
    using Arrays for uint256[];
    /* ============ Structs ============ *
    /** 
    * @dev See {OpenZeppelin - ERC20Snapshot}
    * Snapshotted values have arrays of ids (time) and the value corresponding to that id.
    * ids is expected to be sorted in ascending order, and to contain no repeated elements 
    * because we use findUpperBound in the function _valueAt
    */
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }
    /* ============ Events ============ */
    /**
    @notice Emitted when the snapshot with the specified oldTime was scheduled or rescheduled at the specified newTime.
    */
    event SnapshotSchedule(uint256 indexed oldTime, uint256 indexed newTime);

    /** 
    * @notice Emitted when the scheduled snapshot with the specified time was cancelled.
    */
    event SnapshotUnschedule(uint256 indexed time);

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.SnapshotModuleBase")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SnapshotModuleBaseStorageLocation = 0x649d9af4a0486294740af60c5e3bf61210e7b49108a80b1f369042ea9fd02000;
    /* ==== ERC-7201 State Variables === */
    struct SnapshotModuleBaseStorage {
        /**
        * @dev See {OpenZeppelin - ERC20Snapshot}
        */
        mapping(address => Snapshots) _accountBalanceSnapshots;
        Snapshots _totalSupplySnapshots;
        /**
        * @dev time instead of a counter for OpenZeppelin
        */
        // Initialized to zero
        uint256  _currentSnapshotTime;
        // Initialized to zero
        uint256  _currentSnapshotIndex;
        /** 
        * @dev 
        * list of scheduled snapshot (time)
        * This list is sorted in ascending order
        */
        uint256[] _scheduledSnapshots;
    }
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    function __SnapshotModuleBase_init_unchained() internal onlyInitializing {
        // Nothing to do
        // _currentSnapshotTime & _currentSnapshotIndex are initialized to zero
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /** 
    *  
    * @notice Get all snapshots
    */
    function getAllSnapshots() public view returns (uint256[] memory) {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        return $._scheduledSnapshots;
    }

    /** 
    * @dev 
    * Get the next scheduled snapshots
    */
    function getNextSnapshots() public view returns (uint256[] memory) {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        uint256[] memory nextScheduledSnapshot = new uint256[](0);
        // no snapshot were planned
        if ($._scheduledSnapshots.length > 0) {
            (
                uint256 timeLowerBound,
                uint256 indexLowerBound
            ) = _findScheduledMostRecentPastSnapshot();
            // All snapshots are situated in the futur
            if ((timeLowerBound == 0) && ($._currentSnapshotTime == 0)) {
                return $._scheduledSnapshots;
            } else {
                // There are snapshots situated in the futur
                if (indexLowerBound + 1 != $._scheduledSnapshots.length) {
                    // All next snapshots are located after the snapshot specified by indexLowerBound
                    uint256 arraySize = $._scheduledSnapshots.length -
                        indexLowerBound -
                        1;
                    nextScheduledSnapshot = new uint256[](arraySize);
                    // No need of unchecked block since Soliditiy 0.8.22
                    for (uint256 i; i < arraySize; ++i) {
                        nextScheduledSnapshot[i] = $._scheduledSnapshots[
                            indexLowerBound + 1 + i
                        ];
                    }
                }
            }
        }
        return nextScheduledSnapshot;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /** 
    * @dev schedule a snapshot at the specified time
    * You can only add a snapshot after the last previous
    */
    function _scheduleSnapshot(uint256 time) internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        // Check the time firstly to avoid an useless read of storage
       _checkTimeInThePast(time);

        if ($._scheduledSnapshots.length > 0) {
            // We check the last snapshot on the list
            uint256 nextSnapshotTime = $._scheduledSnapshots[
                $._scheduledSnapshots.length - 1
            ];
            if (time < nextSnapshotTime) {
                revert SnapshotErrors
                    .CMTAT_SnapshotModule_SnapshotTimestampBeforeLastSnapshot(
                        time,
                        nextSnapshotTime
                    );
            } else if (time == nextSnapshotTime) {
                revert SnapshotErrors.CMTAT_SnapshotModule_SnapshotAlreadyExists();
            }
        }
        $._scheduledSnapshots.push(time);
        emit SnapshotSchedule(0, time);
    }

    /** 
    * @dev schedule a snapshot at the specified time
    */
    function _scheduleSnapshotNotOptimized(uint256 time) internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        _checkTimeInThePast(time);
        (bool isFound, uint256 index) = _findScheduledSnapshotIndex(time);
        // Perfect match
        if (isFound) {
            revert SnapshotErrors.CMTAT_SnapshotModule_SnapshotAlreadyExists();
        }
        // if no upper bound match found, we push the snapshot at the end of the list
        if (index == $._scheduledSnapshots.length) {
            $._scheduledSnapshots.push(time);
        } else {
            $._scheduledSnapshots.push(
                $._scheduledSnapshots[$._scheduledSnapshots.length - 1]
            );
            for (uint256 i = $._scheduledSnapshots.length - 2; i > index; ) {
                $._scheduledSnapshots[i] = $._scheduledSnapshots[i - 1];
                unchecked {
                    --i;
                }
            }
            $._scheduledSnapshots[index] = time;
        }
        emit SnapshotSchedule(0, time);
    }

    /** 
    * @dev reschedule a scheduled snapshot at the specified newTime
    */
    function _rescheduleSnapshot(uint256 oldTime, uint256 newTime) internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        // Check the time firstly to avoid an useless read of storage
        _checkTimeSnapshotAlreadyDone(oldTime);
        _checkTimeInThePast(newTime);
        if ($._scheduledSnapshots.length == 0) {
            revert SnapshotErrors.CMTAT_SnapshotModule_NoSnapshotScheduled();
        }
        uint256 index = _findAndRevertScheduledSnapshotIndex(oldTime);
        if (index + 1 < $._scheduledSnapshots.length) {
            uint256 nextSnapshotTime = $._scheduledSnapshots[index + 1];
            if (newTime > nextSnapshotTime) {
                revert SnapshotErrors
                    .CMTAT_SnapshotModule_SnapshotTimestampAfterNextSnapshot(
                        newTime,
                        nextSnapshotTime
                    );
            } else if (newTime == nextSnapshotTime) {
                revert SnapshotErrors.CMTAT_SnapshotModule_SnapshotAlreadyExists();
            }
        }
        if (index > 0) {
            if (newTime <= $._scheduledSnapshots[index - 1])
                revert SnapshotErrors
                    .CMTAT_SnapshotModule_SnapshotTimestampBeforePreviousSnapshot(
                        newTime,
                        $._scheduledSnapshots[index - 1]
                    );
        }
        $._scheduledSnapshots[index] = newTime;

        emit SnapshotSchedule(oldTime, newTime);
    }

    /**
    * @dev unschedule the last scheduled snapshot
    */
    function _unscheduleLastSnapshot(uint256 time) internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        // Check the time firstly to avoid an useless read of storage
        _checkTimeSnapshotAlreadyDone(time);
        if ($._scheduledSnapshots.length == 0) {
            revert SnapshotErrors.CMTAT_SnapshotModule_NoSnapshotScheduled();
        }
        // All snapshot time are unique, so we do not check the indice
        if (time !=$._scheduledSnapshots[$._scheduledSnapshots.length - 1]) {
            revert SnapshotErrors.CMTAT_SnapshotModule_SnapshotNotFound();
        }
        $._scheduledSnapshots.pop();
        emit SnapshotUnschedule(time);
    }

    /** 
    * @dev unschedule (remove) a scheduled snapshot in three steps:
    * - search the snapshot in the list
    * - If found, move all next snapshots one position to the left
    * - Reduce the array size by deleting the last snapshot
    */
    function _unscheduleSnapshotNotOptimized(uint256 time) internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        _checkTimeSnapshotAlreadyDone(time);
        
        uint256 index = _findAndRevertScheduledSnapshotIndex(time);
        // No need of unchecked block since Soliditiy 0.8.22
        for (uint256 i = index; i + 1 < $._scheduledSnapshots.length; ++i ) {
            $._scheduledSnapshots[i] = $._scheduledSnapshots[i + 1];
        }
        $._scheduledSnapshots.pop();
    }

    /**
    * @dev See {OpenZeppelin - ERC20Snapshot}
    * @param time where we want a snapshot
    * @param snapshots the struct where are stored the snapshots
    * @return  snapshotExist true if a snapshot is found, false otherwise
    * value 0 if no snapshot, balance value if a snapshot exists
    */
    function _valueAt(
        uint256 time,
        Snapshots storage snapshots
    ) internal view returns (bool snapshotExist, uint256 value) {
        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(time);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    /** 
    * @dev 
    * Inside a struct Snapshots:
    * - Update the array ids to the current Snapshot time if this one is greater than the snapshot times stored in ids.
    * - Update the value to the corresponding value.
    */
    function _updateSnapshot(
        Snapshots storage snapshots,
        uint256 currentValue
    ) internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        uint256 current = $._currentSnapshotTime;
        if (_lastSnapshot(snapshots.ids) < current) {
            snapshots.ids.push(current);
            snapshots.values.push(currentValue);
        }
    }

    /** 
    * @dev
    * Set the currentSnapshotTime by retrieving the most recent snapshot
    * if a snapshot exists, clear all past scheduled snapshot
    */
    function _setCurrentSnapshot() internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        (
            uint256 scheduleSnapshotTime,
            uint256 scheduleSnapshotIndex
        ) = _findScheduledMostRecentPastSnapshot();
        if (scheduleSnapshotTime > 0) {
            $._currentSnapshotTime = scheduleSnapshotTime;
            $._currentSnapshotIndex = scheduleSnapshotIndex;
        }
    }

    /**
    * @return the last snapshot time inside a snapshot ids array
    */
    function _lastSnapshot(
        uint256[] storage ids
    ) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    /** 
    * @dev Find the snapshot index at the specified time
    * @return (true, index) if the snapshot exists, (false, 0) otherwise
    */
    function _findScheduledSnapshotIndex(
        uint256 time
    ) private view returns (bool, uint256) {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        uint256 indexFound = $._scheduledSnapshots.findUpperBound(time);
        uint256 _scheduledSnapshotsLength = $._scheduledSnapshots.length;
        // Exact match
        if (
            indexFound != _scheduledSnapshotsLength &&
            $._scheduledSnapshots[indexFound] == time
        ) {
            return (true, indexFound);
        }
        // Upper bound match
        else if (indexFound != _scheduledSnapshotsLength) {
            return (false, indexFound);
        }
        // no match
        else {
            return (false, _scheduledSnapshotsLength);
        }
    }

    /** 
    * @dev find the most recent past snapshot
    * The complexity of this function is O(N) because we go through the whole list
    */
    function _findScheduledMostRecentPastSnapshot()
        private
        view
        returns (uint256 time, uint256 index)
    {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        uint256 currentArraySize = $._scheduledSnapshots.length;
        // no snapshot or the current snapshot already points on the last snapshot
        if (
            currentArraySize == 0 ||
            (($._currentSnapshotIndex + 1 == currentArraySize) && (time != 0))
        ) {
            return (0, currentArraySize);
        }
        // mostRecent is initialized in the loop
        uint256 mostRecent;
        index = currentArraySize;
        // No need of unchecked block since Soliditiy 0.8.22
        for (uint256 i = $._currentSnapshotIndex; i < currentArraySize; ++i ) {
            if ($._scheduledSnapshots[i] <= block.timestamp) {
                mostRecent = $._scheduledSnapshots[i];
                index = i;
            } else {
                // All snapshot are planned in the futur
                break;
            }
        }
        return (mostRecent, index);
    }

    /* ============ Require balance and total supply ============ */

    /**
    * @dev See {OpenZeppelin - ERC20Snapshot}
    */
    function _updateAccountSnapshot(address account, uint256 accountBalance) internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        _updateSnapshot($._accountBalanceSnapshots[account], accountBalance);
    }

    /**
    * @dev See {OpenZeppelin - ERC20Snapshot}
    */
    function _updateTotalSupplySnapshot(uint256 totalSupply) internal {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        _updateSnapshot($._totalSupplySnapshots, totalSupply);
    }

       /** 
    * @notice Return the number of tokens owned by the given owner at the time when the snapshot with the given time was created.
    * @return value stored in the snapshot, or the actual balance if no snapshot
    */
    function _snapshotBalanceOf(
        uint256 time,
        address owner,
        uint256 ownerBalance
    ) internal view returns (uint256) {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        (bool snapshotted, uint256 value) = _valueAt(
            time,
            $._accountBalanceSnapshots[owner]
        );
        return snapshotted ? value :  ownerBalance;
    }

    /**
    * @dev See {OpenZeppelin - ERC20Snapshot}
    * Retrieves the total supply at the specified time.
    * @return value stored in the snapshot, or the actual totalSupply if no snapshot
    */
    function _snapshotTotalSupply(uint256 time, uint256 totalSupply) internal view returns (uint256) {
        SnapshotModuleBaseStorage storage $ = _getSnapshotModuleBaseStorage();
        (bool snapshotted, uint256 value) = _valueAt(
            time,
            $._totalSupplySnapshots
        );
        return snapshotted ? value : totalSupply;
    }

    /* ============ Utility functions ============ */


    function _findAndRevertScheduledSnapshotIndex(
        uint256 time
    ) private view returns (uint256){
        (bool isFound, uint256 index) = _findScheduledSnapshotIndex(time);
        if (!isFound) {
            revert SnapshotErrors.CMTAT_SnapshotModule_SnapshotNotFound();
        }
        return index;
    }
    function _checkTimeInThePast(uint256 time) internal view{
        if (time <= block.timestamp) {
                    revert SnapshotErrors.CMTAT_SnapshotModule_SnapshotScheduledInThePast(
                        time,
                        block.timestamp
                    );
                }
    }
    function _checkTimeSnapshotAlreadyDone(uint256 time) internal view{
        if (time <= block.timestamp) {
            revert SnapshotErrors.CMTAT_SnapshotModule_SnapshotAlreadyDone();
        }
    }

    /* ============ ERC-7201 ============ */
    function _getSnapshotModuleBaseStorage() internal pure returns (SnapshotModuleBaseStorage storage $) {
        assembly {
            $.slot := SnapshotModuleBaseStorageLocation
        }
    }
}
