//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/utils/ArraysUpgradeable.sol";

/**
 * @dev Snapshot module.
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 */

abstract contract SnapshotModule is Initializable, ContextUpgradeable, ERC20Upgradeable {
  using ArraysUpgradeable for uint256[];

  event SnapshotSchedule(uint256 indexed oldTime, uint256 indexed newTime);
  event SnapshotUnschedule(uint256 indexed time);

  struct Snapshots {
    uint256[] ids;
    uint256[] values;
  }
  
  bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");
  mapping(address => Snapshots) private _accountBalanceSnapshots;
  Snapshots private _totalSupplySnapshots;

  uint256 private _currentSnapshot = 0;

  uint256[] private _scheduledSnapshots;

  function __Snapshot_init() internal initializer {
    __Context_init_unchained();
    __Snapshot_init_unchained();
  }

  function __Snapshot_init_unchained() internal initializer {
  }

  function _scheduleSnapshot (uint256 time) internal returns (uint256) {
    require(block.timestamp < time, "Snapshot scheduled in the past");
    (bool found, ) = _findScheduledSnapshotIndex(time);
    require(!found, "Snapshot already scheduled for this time");
    _scheduledSnapshots.push(time);
    emit SnapshotSchedule(0, time);
    return time;
  }

  function _rescheduleSnapshot (uint256 oldTime, uint256 newTime) internal returns (uint256) {
    require(block.timestamp < oldTime, "Snapshot already done");
    require(block.timestamp < newTime, "Snapshot scheduled in the past");

    (bool foundNew, ) = _findScheduledSnapshotIndex(newTime);
    require(!foundNew, "Snapshot already scheduled for this time");

    (bool foundOld, uint256 index) = _findScheduledSnapshotIndex(oldTime);
    require(foundOld, "Snapshot not found");

    _scheduledSnapshots[index] = newTime;

    emit SnapshotSchedule(oldTime, newTime);
    return newTime;
  }

  function _unscheduleSnapshot (uint256 time) internal returns (uint256) {
    require(block.timestamp < time, "Snapshot already done");
    (bool found, uint256 index) = _findScheduledSnapshotIndex(time);
    require(found, "Snapshot not found");

    _removeScheduledItem(index);

    emit SnapshotUnschedule(time);

    return time;
  }

  function getNextSnapshots () public view returns (uint256[] memory) {
    return _scheduledSnapshots;
  }

  function snapshotBalanceOf (uint256 time, address owner) public view returns (uint256) {
    (bool snapshotted, uint256 value) = _valueAt(time, _accountBalanceSnapshots[owner]);

    return snapshotted ? value : balanceOf(owner);
  }

  function snapshotTotalSupply (uint256 time) public view returns (uint256) {
    (bool snapshotted, uint256 value) = _valueAt(time, _totalSupplySnapshots);

    return snapshotted ? value : totalSupply();
  }

  // Update balance and/or total supply snapshots before the values are modified. This is implemented
  // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
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

  function _valueAt(uint256 time, Snapshots storage snapshots) private view returns (bool, uint256) {
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

  function _updateAccountSnapshot(address account) private {
    _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
  }

  function _updateTotalSupplySnapshot() private {
    _updateSnapshot(_totalSupplySnapshots, totalSupply());
  }

  function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
    uint256 current = _getCurrentSnapshot();
    if (_lastSnapshot(snapshots.ids) < current) {
      snapshots.ids.push(current);
      snapshots.values.push(currentValue);
    }
  }

  function _setCurrentSnapshot() internal {
    (uint256 time) = _findScheduledMostRecentPastSnapshot();
    if (time > 0) {
      _currentSnapshot = time;
      _clearPastScheduled();
    }
  }

  function _getCurrentSnapshot() internal view virtual returns (uint256) {
    return _currentSnapshot;
  }

  function _lastSnapshot(uint256[] storage ids) private view returns (uint256) {
    if (ids.length == 0) {
      return 0;
    } else {
      return ids[ids.length - 1];
    }
  }

  function _findScheduledSnapshotIndex(uint256 time) private view returns (bool, uint256) {
    for (uint256 i=0; i<_scheduledSnapshots.length; i++) {
      if (_scheduledSnapshots[i] == time) {
        return (true, i);
      }
    }
    return (false, 0);
  }

  function _findScheduledMostRecentPastSnapshot() private view returns (uint256) {
    if (_scheduledSnapshots.length == 0) return 0;
    uint256 mostRecent = 0;
    for (uint256 i=0; i<_scheduledSnapshots.length; i++) {
      if (_scheduledSnapshots[i] <= block.timestamp && _scheduledSnapshots[i] > mostRecent) {
        mostRecent = _scheduledSnapshots[i];
      }
    }
    return mostRecent;
  }

  function _clearPastScheduled() private {
    uint256 i = 0;
    while (i < _scheduledSnapshots.length) {
      if (_scheduledSnapshots[i] <= block.timestamp) {
        _removeScheduledItem(i);
      } else {
        i += 1;
      }
    }
  }

  function _removeScheduledItem(uint256 index) private {
    _scheduledSnapshots[index] = _scheduledSnapshots[_scheduledSnapshots.length-1];
    _scheduledSnapshots.pop();
  }
  
  uint256[50] private __gap;
}
