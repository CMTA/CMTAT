//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {Arrays} from '@openzeppelin/contracts/utils/Arrays.sol';
import "./base/SnapshotModuleBase.sol";
import "../../interfaces/ICMTATSnapshot.sol";
/**
 * @dev Snapshot module internal.
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 * Inspired by Openzeppelin - ERC20Snapshot but use the time as Id instead of a counter.
 * Contrary to OpenZeppelin, the function _getCurrentSnapshotId is not available 
   because overriding this function can break the contract.
 */

abstract contract ERC20SnapshotModuleInternal is ICMTATSnapshot, SnapshotModuleBase, ERC20Upgradeable {
    using Arrays for uint256[];
    /* ============  Initializer Function ============ */
    function __ERC20Snapshot_init_unchained() internal onlyInitializing {
        // Nothing to do
        // _currentSnapshotTime & _currentSnapshotIndex are initialized to zero
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @notice Return snapshotBalanceOf and snapshotTotalSupply to avoid multiple calls
    * @return ownerBalance ,  totalSupply - see snapshotBalanceOf and snapshotTotalSupply
    */
    function snapshotInfo(uint256 time, address owner) public view returns (uint256 ownerBalance, uint256 totalSupply) {
        ownerBalance = snapshotBalanceOf(time, owner);
        totalSupply = snapshotTotalSupply(time);
    }

    /**
    * @notice Return snapshotBalanceOf for each address in the array and the total supply
    * @return ownerBalances array with the balance of each address, the total supply
    */
    function snapshotInfoBatch(uint256 time, address[] calldata addresses) public view returns (uint256[] memory ownerBalances, uint256 totalSupply) {
        ownerBalances = new uint256[](addresses.length);
        for(uint256 i = 0; i < addresses.length; ++i){
             ownerBalances[i]  = snapshotBalanceOf(time, addresses[i]);
        }
        totalSupply = snapshotTotalSupply(time);
    }

    /**
    * @notice Return snapshotBalanceOf for each address in the array and the total supply
    * @return ownerBalances array with the balance of each address, the total supply
    */
    function snapshotInfoBatch(uint256[] calldata times, address[] calldata addresses) public view returns (uint256[][] memory ownerBalances, uint256[] memory totalSupply) {
        ownerBalances = new uint256[][](times.length);
        totalSupply = new uint256[](times.length);
        for(uint256 iT = 0; iT < times.length; ++iT){
            (ownerBalances[iT], totalSupply[iT]) = snapshotInfoBatch(times[iT],addresses);
        }
    }

    /** 
    * @notice Return the number of tokens owned by the given owner at the time when the snapshot with the given time was created.
    * @return value stored in the snapshot, or the actual balance if no snapshot
    */
    function snapshotBalanceOf(
        uint256 time,
        address owner
    ) public view returns (uint256) {
        return _snapshotBalanceOf(time, owner, balanceOf(owner));
    }

    /**
    * @dev See {OpenZeppelin - ERC20Snapshot}
    * Retrieves the total supply at the specified time.
    * @return value stored in the snapshot, or the actual totalSupply if no snapshot
    */
    function snapshotTotalSupply(uint256 time) public view returns (uint256) {
        return _snapshotTotalSupply(time, totalSupply());
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

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
            _updateAccountSnapshot(from, balanceOf(from));
            if (to != address(0)) {
                // transfer
                _updateAccountSnapshot(to, balanceOf(to));
            } else {
                // burn
                _updateTotalSupplySnapshot(totalSupply());
            }
        } else {
            // mint
            _updateAccountSnapshot(to, balanceOf(to));
            _updateTotalSupplySnapshot(totalSupply());
        }
    }
}
