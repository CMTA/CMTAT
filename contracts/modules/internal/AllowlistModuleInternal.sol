//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {EnforcementModuleLibrary} from "./common/EnforcementModuleLibrary.sol";
/**
 * @dev Allowlist module internal.
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract AllowlistModuleInternal is
    Initializable,
    ContextUpgradeable
{
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.AllowlistModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AllowlistModuleInternalStorageLocation = 0x53076eaf2d1e2f915f2e0487c9f92cca686c37fd47bf11f95f0da313b2809800;
    
    /* ==== ERC-7201 State Variables === */
    struct AllowlistModuleInternalStorage {
        bool _enableAllowlist;
        mapping(address account => bool status) _allowlist;
    }
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    function __Allowlist_init_unchained() internal onlyInitializing {
         AllowlistModuleInternalStorage storage $ = _getAllowlistModuleInternalStorage();
         $._enableAllowlist = true;
        // no variable to initialize
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State functions ============ */

    function _addToAllowlist(address account, bool status, bytes memory data) internal virtual{
        AllowlistModuleInternalStorage storage $ = _getAllowlistModuleInternalStorage();
        _addToAllowlist($, account, status, data);
    }

    function _addToAllowlist(AllowlistModuleInternalStorage storage $,address account, bool status, bytes memory /*data */) internal virtual{
        $._allowlist[account] = status;
    }

    function _addToAllowlist(address[] calldata accounts, bool[] calldata status, bytes memory data) internal virtual{
        EnforcementModuleLibrary._checkInput(accounts, status);
        AllowlistModuleInternalStorage storage $ = _getAllowlistModuleInternalStorage();
        for (uint256 i = 0; i < accounts.length; ++i) {
            _addToAllowlist($, accounts[i], status[i], data);
        }
    }

    /**
     * @dev enable or disable the allowlist depending of `status` parameter
     */
    function _enableAllowlist(bool status) internal virtual {
        AllowlistModuleInternalStorage storage $ = _getAllowlistModuleInternalStorage();
        $._enableAllowlist = status;
    }

    /* ============ View functions ============ */
    /**
     * @dev Returns true if the account is listed, and false otherwise.
     */
    function _isAllowlisted(address account) internal view virtual returns (bool) {
        AllowlistModuleInternalStorage storage $ = _getAllowlistModuleInternalStorage();
        return $._allowlist[account];
    }

    /**
     * @dev Returns true if the list is enabled, false otherwise
     */
    function _isAllowlistEnabled() internal view virtual returns (bool) {
        AllowlistModuleInternalStorage storage $ = _getAllowlistModuleInternalStorage();
        return $._enableAllowlist;
    }



    /* ============ ERC-7201 ============ */
    function _getAllowlistModuleInternalStorage() internal pure returns (AllowlistModuleInternalStorage storage $) {
        assembly {
            $.slot := AllowlistModuleInternalStorageLocation
        }
    }
}
