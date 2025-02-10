//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {SnapshotModuleBase} from "./library/snapshot/SnapshotModuleBase.sol";
import {ICMTATSnapshot} from "./library/snapshot/ICMTATSnapshot.sol";
import {ISnapshotEngine} from "../interfaces/engine/ISnapshotEngine.sol";
/*
* @title a RuleEngine mock for testing, not suitable for production
*/
contract SnapshotEngineMock is SnapshotModuleBase, AccessControlUpgradeable, ISnapshotEngine {
    ERC20Upgradeable erc20;
    constructor(ERC20Upgradeable erc20_, address admin) {
        erc20 = erc20_;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }
        /* ============ State Variables ============ */
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");

    /** 
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable) returns (bool) {
        // The Default Admin has all roles
        if (AccessControlUpgradeable.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        }
        return AccessControlUpgradeable.hasRole(role, account);
    }
    /** 
    * @dev Update balance and/or total supply snapshots before the values are modified. This is implemented
    * in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    */
   function operateOnTransfer(address from, address to, uint256 balanceFrom, uint256 balanceTo, uint256 totalSupply) public override {
        _setCurrentSnapshot();
        if (from != address(0)) {
            // for both burn and transfer
            _updateAccountSnapshot(from, balanceFrom);
            if (to != address(0)) {
                // transfer
                _updateAccountSnapshot(to, balanceTo);
            } else {
                // burn
                _updateTotalSupplySnapshot(totalSupply);
            }
        } else {
            // mint
            _updateAccountSnapshot(to, balanceTo);
            _updateTotalSupplySnapshot(totalSupply);
        }
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
        return _snapshotBalanceOf(time, owner, erc20.balanceOf(owner));
    }

    /**
    * @dev See {OpenZeppelin - ERC20Snapshot}
    * Retrieves the total supply at the specified time.
    * @return value stored in the snapshot, or the actual totalSupply if no snapshot
    */
    function snapshotTotalSupply(uint256 time) public view returns (uint256) {
        return _snapshotTotalSupply(time, erc20.totalSupply());
    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /** 
    * @notice 
    * Schedule a snapshot at the given time specified as a number of seconds since epoch.
    * The time cannot be before the time of the latest scheduled, but not yet created snapshot.  
    */
    function scheduleSnapshot(uint256 time) public onlyRole(SNAPSHOOTER_ROLE) {
        _scheduleSnapshot(time);
    }

    /** 
    * @notice 
    * Schedule a snapshot at the given time specified as a number of seconds since epoch.
    * The time cannot be before the time of the latest scheduled, but not yet created snapshot.  
    */
    function scheduleSnapshotNotOptimized(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _scheduleSnapshotNotOptimized(time);
    }

    /** 
    * @notice
    * Reschedule the scheduled snapshot, but not yet created snapshot with the given oldTime to be created at the given newTime specified as a number of seconds since epoch. 
    * The newTime cannot be before the time of the previous scheduled, but not yet created snapshot, or after the time fo the next scheduled snapshot. 
    */
    function rescheduleSnapshot(
        uint256 oldTime,
        uint256 newTime
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _rescheduleSnapshot(oldTime, newTime);
    }

    /**
    * @notice 
    * Cancel creation of the scheduled snapshot, but not yet created snapshot with the given time. 
    * There should not be any other snapshots scheduled after this one. 
    */
    function unscheduleLastSnapshot(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _unscheduleLastSnapshot(time);
    }

    /** 
    * @notice 
    * Cancel creation of the scheduled snapshot, but not yet created snapshot with the given time. 
    */
    function unscheduleSnapshotNotOptimized(
        uint256 time
    ) public onlyRole(SNAPSHOOTER_ROLE) {
        _unscheduleSnapshotNotOptimized(time);
    }
}
