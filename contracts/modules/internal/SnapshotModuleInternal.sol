//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/utils/ArraysUpgradeable.sol";

/**
 * @dev Snapshot module.
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 * Inspired by Openzeppelin - ERC20Snapshot but use the time as Id instead of a counter.
 * Contrary to OpenZeppelin, the function _getCurrentSnapshotId is not available 
   because overriding this function can break the contract.
 */

abstract contract SnapshotModuleInternal is ERC20Upgradeable {
    using ArraysUpgradeable for uint256[];

    /**
    @notice Emitted when the snapshot with the specified oldTime was scheduled or rescheduled at the specified newTime.
    */
    event SnapshotSchedule(uint256 indexed oldTime, uint256 indexed newTime);

    /** 
    @notice Emitted when the scheduled snapshot with the specified time was cancelled.
    */
    event SnapshotUnschedule(uint256 indexed time);

    /** 
    @dev See {OpenZeppelin - ERC20Snapshot}
    Snapshotted values have arrays of ids (time) and the value corresponding to that id.
    ids is expected to be sorted in ascending order, and to contain no repeated elements 
    because we use findUpperBound in the function _valueAt
    */
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    /**
    @dev See {OpenZeppelin - ERC20Snapshot}
    */
    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    /**
    @dev time instead of a counter for OpenZeppelin
    */
    uint256 private _currentSnapshotTime;
    uint256 private _currentSnapshotIndex;

    /** 
    @dev 
    list of scheduled snapshot (time)
    This list is sorted in ascending order
    */
    uint256[] private _scheduledSnapshots;

    /**
     * @dev Initializes the contract
     */
    function __Snapshot_init(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        __Context_init_unchained();
        __ERC20_init(name_, symbol_);
        __Snapshot_init_unchained();
    }

    function __Snapshot_init_unchained() internal onlyInitializing {
        _currentSnapshotTime = 0;
        _currentSnapshotIndex = 0;
    }

    /** 
    @dev schedule a snapshot at the specified time
    You can only add a snapshot after the last previous
    */
    function _scheduleSnapshot(uint256 time) internal {
        // Check the time firstly to avoid an useless read of storage
        require(time > block.timestamp, "Snapshot scheduled in the past");

        if (_scheduledSnapshots.length > 0) {
            // We check the last snapshot on the list
            require(
                time > _scheduledSnapshots[_scheduledSnapshots.length - 1],
                "time has to be greater than the last snapshot time"
            );
        }
        _scheduledSnapshots.push(time);
        emit SnapshotSchedule(0, time);
    }

    /** 
    @dev schedule a snapshot at the specified time
    */
    function _scheduleSnapshotNotOptimized(uint256 time) internal {
        require(time > block.timestamp, "Snapshot scheduled in the past");
        (bool isFound, uint256 index) = _findScheduledSnapshotIndex(time);
        // Perfect match
        require(!isFound, "Snapshot already exists");
        // if no upper bound match found, we push the snapshot at the end of the list
        if (index == _scheduledSnapshots.length) {
            _scheduledSnapshots.push(time);
        } else {
            _scheduledSnapshots.push(
                _scheduledSnapshots[_scheduledSnapshots.length - 1]
            );
            for (uint256 i = _scheduledSnapshots.length - 2; i > index; ) {
                _scheduledSnapshots[i] = _scheduledSnapshots[i - 1];
                unchecked {
                    --i;
                }
            }
            _scheduledSnapshots[index] = time;
        }
        emit SnapshotSchedule(0, time);
    }

    /** 
    @dev reschedule a scheduled snapshot at the specified newTime
    */
    function _rescheduleSnapshot(uint256 oldTime, uint256 newTime) internal {
        // Check the time firstly to avoid an useless read of storage
        require(oldTime > block.timestamp, "Snapshot already done");
        require(newTime > block.timestamp, "Snapshot scheduled in the past");
        require(_scheduledSnapshots.length > 0, "no scheduled snapshot");

        (bool foundOld, uint256 index) = _findScheduledSnapshotIndex(oldTime);
        require(foundOld, "Snapshot not found");

        if (index + 1 < _scheduledSnapshots.length) {
            require(
                newTime < _scheduledSnapshots[index + 1],
                "time has to be less than the next snapshot"
            );
        }

        if (index > 0) {
            require(
                newTime > _scheduledSnapshots[index - 1],
                "time has to be greater than the previous snapshot"
            );
        }

        _scheduledSnapshots[index] = newTime;

        emit SnapshotSchedule(oldTime, newTime);
    }

    /**
    @dev unschedule the last scheduled snapshot
    */
    function _unscheduleLastSnapshot(uint256 time) internal {
        // Check the time firstly to avoid an useless read of storage
        require(time > block.timestamp, "Snapshot already done");
        require(_scheduledSnapshots.length > 0, "No snapshot scheduled");
        // All snapshot time are unique, so we do not check the indice
        require(
            time == _scheduledSnapshots[_scheduledSnapshots.length - 1],
            "Only the last snapshot can be unscheduled"
        );
        _scheduledSnapshots.pop();
        emit SnapshotUnschedule(time);
    }

    /** 
    @dev unschedule (remove) a scheduled snapshot in three steps:
    - search the snapshot in the list
    - If found, move all next snapshots one position to the left
    - Reduce the array size by deleting the last snapshot
    */
    function _unscheduleSnapshotNotOptimized(uint256 time) internal {
        require(time > block.timestamp, "Snapshot already done");
        (bool isFound, uint256 index) = _findScheduledSnapshotIndex(time);
        require(isFound, "Snapshot not found");
        for (uint256 i = index; i + 1 < _scheduledSnapshots.length; ) {
            _scheduledSnapshots[i] = _scheduledSnapshots[i + 1];
            unchecked {
                ++i;
            }
        }
        _scheduledSnapshots.pop();
    }

    /** 
    @dev 
    Get the next scheduled snapshots
    */
    function getNextSnapshots() public view returns (uint256[] memory) {
        uint256[] memory nextScheduledSnapshot = new uint256[](0);
        // no snapshot were planned
        if (_scheduledSnapshots.length > 0) {
            (
                uint256 timeLowerBound,
                uint256 indexLowerBound
            ) = _findScheduledMostRecentPastSnapshot();
            // All snapshots are situated in the futur
            if ((timeLowerBound == 0) && (_currentSnapshotTime == 0)) {
                return _scheduledSnapshots;
            } else {
                // There are snapshots situated in the futur
                if (indexLowerBound + 1 != _scheduledSnapshots.length) {
                    // All next snapshots are located after the snapshot specified by indexLowerBound
                    uint256 arraySize = _scheduledSnapshots.length -
                        indexLowerBound -
                        1;
                    nextScheduledSnapshot = new uint256[](arraySize);
                    for (uint256 i = 0; i < nextScheduledSnapshot.length; ++i) {
                        nextScheduledSnapshot[i] = _scheduledSnapshots[
                            indexLowerBound + 1 + i
                        ];
                    }
                }
            }
        }
        return nextScheduledSnapshot;
    }

    /** 
    @dev 
    Get all snapshots
    */
    function getAllSnapshots() public view returns (uint256[] memory) {
        return _scheduledSnapshots;
    }

    /** 
    @notice Return the number of tokens owned by the given owner at the time when the snapshot with the given time was created.
    @return value stored in the snapshot, or the actual balance if no snapshot
    */
    function snapshotBalanceOf(
        uint256 time,
        address owner
    ) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(
            time,
            _accountBalanceSnapshots[owner]
        );

        return snapshotted ? value : balanceOf(owner);
    }

    /**
    @dev See {OpenZeppelin - ERC20Snapshot}
    Retrieves the total supply at the specified time.
    @return value stored in the snapshot, or the actual totalSupply if no snapshot
    */
    function snapshotTotalSupply(uint256 time) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(
            time,
            _totalSupplySnapshots
        );
        return snapshotted ? value : totalSupply();
    }

    /** 
    @dev Update balance and/or total supply snapshots before the values are modified. This is implemented
    in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        _setCurrentSnapshot();
        if (from != address(0)) {
            // for both burn and transfer
            _updateAccountSnapshot(from);
            if (to != address(0)) {
                // transfer
                _updateAccountSnapshot(to);
            } else {
                // burn
                _updateTotalSupplySnapshot();
            }
        } else {
            // mint
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        }
    }

    /**
    @dev See {OpenZeppelin - ERC20Snapshot}
    @param time where we want a snapshot
    @param snapshots the struct where are stored the snapshots
    @return  snapshotExist true if a snapshot is found, false otherwise
    value 0 if no snapshot, balance value if a snapshot exists
    */
    function _valueAt(
        uint256 time,
        Snapshots storage snapshots
    ) private view returns (bool snapshotExist, uint256 value) {
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
    @dev See {OpenZeppelin - ERC20Snapshot}
    */
    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    /**
    @dev See {OpenZeppelin - ERC20Snapshot}
    */
    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    /** 
    @dev 
    Inside a struct Snapshots:
    - Update the array ids to the current Snapshot time if this one is greater than the snapshot times stored in ids.
    - Update the value to the corresponding value.
    */
    function _updateSnapshot(
        Snapshots storage snapshots,
        uint256 currentValue
    ) private {
        uint256 current = _currentSnapshotTime;
        if (_lastSnapshot(snapshots.ids) < current) {
            snapshots.ids.push(current);
            snapshots.values.push(currentValue);
        }
    }

    /** 
    @dev
    Set the currentSnapshotTime by retrieving the most recent snapshot
    if a snapshot exists, clear all past scheduled snapshot
    */
    function _setCurrentSnapshot() internal {
        (
            uint256 scheduleSnapshotTime,
            uint256 scheduleSnapshotIndex
        ) = _findScheduledMostRecentPastSnapshot();
        if (scheduleSnapshotTime > 0) {
            _currentSnapshotTime = scheduleSnapshotTime;
            _currentSnapshotIndex = scheduleSnapshotIndex;
        }
    }

    /**
    @return the last snapshot time inside a snapshot ids array
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
    @dev Find the snapshot index at the specified time
    @return (true, index) if the snapshot exists, (false, 0) otherwise
    */
    function _findScheduledSnapshotIndex(
        uint256 time
    ) private view returns (bool, uint256) {
        uint256 indexFound = _scheduledSnapshots.findUpperBound(time);
        // Exact match
        if (
            indexFound != _scheduledSnapshots.length &&
            _scheduledSnapshots[indexFound] == time
        ) {
            return (true, indexFound);
        }
        // Upper bound match
        else if (indexFound != _scheduledSnapshots.length) {
            return (false, indexFound);
        }
        // no match
        else {
            return (false, _scheduledSnapshots.length);
        }
    }

    /** 
    @dev find the most recent past snapshot
    The complexity of this function is O(N) because we go through the whole list
    */
    function _findScheduledMostRecentPastSnapshot()
        private
        view
        returns (uint256 time, uint256 index)
    {
        uint256 currentArraySize = _scheduledSnapshots.length;
        // no snapshot or the current snapshot already points on the last snapshot
        if (
            currentArraySize == 0 ||
            ((_currentSnapshotIndex + 1 == currentArraySize) && (time != 0))
        ) {
            return (0, currentArraySize);
        }
        uint256 mostRecent = 0;
        index = currentArraySize;
        for (uint256 i = _currentSnapshotIndex; i < currentArraySize; ++i) {
            if (_scheduledSnapshots[i] <= block.timestamp) {
                mostRecent = _scheduledSnapshots[i];
                index = i;
            } else {
                // All snapshot are planned in the futur
                break;
            }
        }
        return (mostRecent, index);
    }

    uint256[50] private __gap;
}
