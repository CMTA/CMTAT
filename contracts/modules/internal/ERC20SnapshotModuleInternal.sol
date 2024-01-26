//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import {Arrays} from '@openzeppelin/contracts/utils/Arrays.sol';

import "../../libraries/Errors.sol";
import "./base/SnapshotModuleBase.sol";
/**
 * @dev Snapshot module internal.
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 * Inspired by Openzeppelin - ERC20Snapshot but use the time as Id instead of a counter.
 * Contrary to OpenZeppelin, the function _getCurrentSnapshotId is not available 
   because overriding this function can break the contract.
 */

abstract contract ERC20SnapshotModuleInternal is SnapshotModuleBase, ERC20Upgradeable {
    using Arrays for uint256[];


    /** 
    * @dev 
    * list of scheduled snapshot (time)
    * This list is sorted in ascending order
    */
    uint256[] private _scheduledSnapshots;

    function __ERC20Snapshot_init_unchained() internal onlyInitializing {
        // Nothing to do
        // _currentSnapshotTime & _currentSnapshotIndex are initialized to zero
    }


    /** 
    * @dev Update balance and/or total supply snapshots before the values are modified. This is implemented
    * in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    */
    function _snapshotUpdate(
        address from,
        address to
    ) internal virtual  {
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
    * @dev See {OpenZeppelin - ERC20Snapshot}
    */
    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    /**
    * @dev See {OpenZeppelin - ERC20Snapshot}
    */
    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    /**
    * @notice Return snapshotBalanceOf and snapshotTotalSupply to avoid multiple calls
    * @return ownerBalance ,  totalSupply - see snapshotBalanceOf and snapshotTotalSupply
    */
    function getSnapshotInfoBatch(uint256 time, address owner) public view returns (uint256 ownerBalance, uint256 totalSupply) {
        ownerBalance = snapshotBalanceOf(time, owner);
        totalSupply = snapshotTotalSupply(time);
    }


    /** 
    * @notice Return the number of tokens owned by the given owner at the time when the snapshot with the given time was created.
    * @return value stored in the snapshot, or the actual balance if no snapshot
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
    * @dev See {OpenZeppelin - ERC20Snapshot}
    * Retrieves the total supply at the specified time.
    * @return value stored in the snapshot, or the actual totalSupply if no snapshot
    */
    function snapshotTotalSupply(uint256 time) public view returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(
            time,
            _totalSupplySnapshots
        );
        return snapshotted ? value : totalSupply();
    }

    uint256[50] private __gap;
}
