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

abstract contract SnapshotModuleInternal is
    Initializable,
    ContextUpgradeable,
    ERC20Upgradeable
{
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

    /** 
    @dev 
    list of scheduled snapshot (time)
    this list can be unordered if a schedule snapshot is removed or rescheduled
    */
    uint256[] private _scheduledSnapshots;

    function __Snapshot_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __Context_init_unchained();
        __ERC20_init(name_, symbol_);
        __Snapshot_init_unchained();
    }

    function __Snapshot_init_unchained() internal onlyInitializing{
        _currentSnapshotTime = 0;
    }

    /** 
    @dev schedule a snapshot at the specified time
    */
    function _scheduleSnapshot(uint256 time) internal {
        require(block.timestamp < time, "Snapshot scheduled in the past");
        (bool found, ) = _findScheduledSnapshotIndex(time);
        require(!found, "Snapshot already scheduled for this time");
        _scheduledSnapshots.push(time);
        emit SnapshotSchedule(0, time);
    }

    /** 
    @dev reschedule a scheduled snapshot at the specified newTime
    */
    function _rescheduleSnapshot(uint256 oldTime, uint256 newTime)
        internal
    {
        require(block.timestamp < oldTime, "Snapshot already done");
        require(block.timestamp < newTime, "Snapshot scheduled in the past");

        (bool foundNew, ) = _findScheduledSnapshotIndex(newTime);
        require(!foundNew, "Snapshot already scheduled for this time");

        (bool foundOld, uint256 index) = _findScheduledSnapshotIndex(oldTime);
        require(foundOld, "Snapshot not found");

        _scheduledSnapshots[index] = newTime;

        emit SnapshotSchedule(oldTime, newTime);
    }

    /**
    @dev unschedule a scheduled snapshot
    */
    function _unscheduleSnapshot(uint256 time) internal {
        require(block.timestamp < time, "Snapshot already done");
        (bool found, uint256 index) = _findScheduledSnapshotIndex(time);
        require(found, "Snapshot not found");

        _removeScheduledItem(index);

        emit SnapshotUnschedule(time);
    }

    /** 
    @dev 
    Get the next scheduled snapshots
    */
    function getNextSnapshots() public view returns (uint256[] memory) {
        return _scheduledSnapshots;
    }

    /** 
    @notice Return the number of tokens owned by the given owner at the time when the snapshot with the given time was created.
    @return value stored in the snapshot, or the actual balance if no snapshot
    */
    function snapshotBalanceOf(uint256 time, address owner)
        public
        view
        returns (uint256)
    {
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
    function _valueAt(uint256 time, Snapshots storage snapshots)
        private
        view
        returns (bool snapshotExist, uint256 value)
    {
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
    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue)
        private
    {
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
        uint256 scheduleSnapshotTime = _findScheduledMostRecentPastSnapshot();
        if (scheduleSnapshotTime > 0) {
            _currentSnapshotTime = scheduleSnapshotTime;
            _clearPastScheduled();
        }
    }

    /**
    @return return the last snapshot time inside a snapshot ids array
    */
    function _lastSnapshot(uint256[] storage ids)
        private
        view
        returns (uint256)
    {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    /** 
    @dev Find the snapshot index at the specific time
    @return (true, index) if the snapshot exists, (false, 0) otherwise
    */
    function _findScheduledSnapshotIndex(uint256 time)
        private
        view
        returns (bool, uint256)
    {
        for (uint256 i = 0; i < _scheduledSnapshots.length; i++) {
            if (_scheduledSnapshots[i] == time) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    /** 
    @dev find the most recent past snapshot
    The complexity of this function is O(N) because we go through the whole list
    */
    function _findScheduledMostRecentPastSnapshot()
        private
        view
        returns (uint256)
    {
        if (_scheduledSnapshots.length == 0) return 0;
        uint256 mostRecent = 0;
        for (uint256 i = 0; i < _scheduledSnapshots.length; i++) {
            if (
                _scheduledSnapshots[i] <= block.timestamp &&
                _scheduledSnapshots[i] > mostRecent
            ) {
                mostRecent = _scheduledSnapshots[i];
            }
        }
        return mostRecent;
    }

    /** 
    @dev remove all past snapshot by calling the function _removeScheduledItem
    The complexity of this function is O(N) because we go through the whole list
    */
    function _clearPastScheduled() private {
        uint256 i = 0;
        uint256 scheduledSnapshotsLength = _scheduledSnapshots.length;
        while (i < scheduledSnapshotsLength) {
            if (_scheduledSnapshots[i] <= block.timestamp) {
                // underflow impossible
                 unchecked { --scheduledSnapshotsLength; }
                _removeScheduledItem(i);
            } else {
                i += 1;
            }
        }
    }

    /** 
    @dev remove a snapshot in two steps:
    - replace the snapshot to remove by the last snapshot
    - remove the last snapshot
    This operation leaves potentially the list in an unordered state
    */
    function _removeScheduledItem(uint256 index) private {
        if(_scheduledSnapshots[index] != _scheduledSnapshots.length - 1){
            _scheduledSnapshots[index] = _scheduledSnapshots[
                _scheduledSnapshots.length - 1
            ];
        }
        _scheduledSnapshots.pop();
    }

    uint256[50] private __gap;
}
