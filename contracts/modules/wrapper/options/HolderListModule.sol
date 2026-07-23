// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
/* ==== Interfaces === */
import {IHolderListModule} from "../../../interfaces/modules/IHolderListModule.sol";

/**
 * @title HolderList module
 * @dev
 *
 * Maintains on-chain the set of addresses holding a non-zero balance, with paginated reads.
 *
 * The set is kept in sync inside {_update}, so every balance change is covered: transfer,
 * transferFrom, mint, burn, forced transfer and cross-chain mint/burn.
 *
 * Gas: the first transfer to a new address writes two slots (EnumerableSet stores the value
 * and its index), and the transfer emptying an account clears them. Transfers between
 * existing holders that leave both balances non-zero cost nothing extra.
 */
abstract contract HolderListModule is ERC20Upgradeable, IHolderListModule {
    using EnumerableSet for EnumerableSet.AddressSet;

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.HolderListModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant HolderListModuleStorageLocation = 0x93edd3717dec98b474d42a698cc89715a70e7eaf60a2dff7170cc742b7b8ca00;

    /* ==== ERC-7201 State Variables === */
    struct HolderListModuleStorage {
        EnumerableSet.AddressSet _holders;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
    * @inheritdoc IHolderListModule
    */
    function holderCount() public view virtual returns (uint256) {
        HolderListModuleStorage storage $ = _getHolderListModuleStorage();
        return $._holders.length();
    }

    /**
    * @inheritdoc IHolderListModule
    */
    function isHolder(address account) public view virtual returns (bool) {
        HolderListModuleStorage storage $ = _getHolderListModuleStorage();
        return $._holders.contains(account);
    }

    /**
    * @inheritdoc IHolderListModule
    * @dev The bound is checked here so that an out-of-range index reverts with
    * {CMTAT_HolderListModule_IndexOutOfBounds} rather than with the `Panic(0x32)` that
    * {EnumerableSet-at} raises on an out-of-bounds array access.
    */
    function holderByIndex(uint256 index) public view virtual returns (address) {
        HolderListModuleStorage storage $ = _getHolderListModuleStorage();
        uint256 holderCountLocal = $._holders.length();
        require(index < holderCountLocal, CMTAT_HolderListModule_IndexOutOfBounds(index, holderCountLocal));
        return $._holders.at(index);
    }

    /**
    * @inheritdoc IHolderListModule
    */
    function holders() public view virtual returns (address[] memory) {
        HolderListModuleStorage storage $ = _getHolderListModuleStorage();
        return $._holders.values();
    }

    /**
    * @inheritdoc IHolderListModule
    * @dev The malformed-range check is evaluated before the upper-bound check, so an inverted
    * range reverts with {CMTAT_HolderListModule_InvalidRange} regardless of where the bounds fall.
    */
    function holdersInRange(uint256 fromIndex, uint256 toIndex) public view virtual returns (address[] memory window) {
        require(fromIndex <= toIndex, CMTAT_HolderListModule_InvalidRange(fromIndex, toIndex));
        HolderListModuleStorage storage $ = _getHolderListModuleStorage();
        uint256 holderCountLocal = $._holders.length();
        require(toIndex <= holderCountLocal, CMTAT_HolderListModule_IndexOutOfBounds(toIndex, holderCountLocal));
        window = new address[](toIndex - fromIndex);
        for (uint256 i = 0; i < window.length; ++i) {
            window[i] = $._holders.at(fromIndex + i);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev Update the holder set after the balances have been written by {ERC20Upgradeable-_update}.
    * The post-update balance is what decides membership, so the sender is evaluated after it has
    * been debited and the receiver after it has been credited.
    */
    function _update(address from, address to, uint256 value) internal virtual override(ERC20Upgradeable) {
        super._update(from, to, value);
        HolderListModuleStorage storage $ = _getHolderListModuleStorage();
        // address(0) is the mint source and the burn sink, never a holder
        if (from != address(0) && balanceOf(from) == 0) {
            if ($._holders.remove(from)) {
                emit HolderRemoved(from);
            }
        }
        // a zero-value transfer to a new address must not make it a holder
        if (to != address(0) && balanceOf(to) != 0) {
            if ($._holders.add(to)) {
                emit HolderAdded(to);
            }
        }
    }

    /* ============ ERC-7201 ============ */
    function _getHolderListModuleStorage() private pure returns (HolderListModuleStorage storage $) {
        assembly {
            $.slot := HolderListModuleStorageLocation
        }
    }
}
