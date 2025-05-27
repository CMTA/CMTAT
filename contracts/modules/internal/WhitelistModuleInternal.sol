//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {EnforcementModuleLibrary} from "./common/EnforcementModuleLibrary.sol";
/**
 * @dev Enforcement module.
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract WhitelistModuleInternal is
    Initializable,
    ContextUpgradeable
{
    bool public activateWhitelist;
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    function __Whitelist_init_unchained() internal onlyInitializing {
         activateWhitelist = true;
        // no variable to initialize
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _addAddressToTheWhitelist(address account, bool status, bytes memory data) internal virtual{
        WhitelistModuleInternalStorage storage $ = _getWhitelistModuleInternalStorage();
        _addAddressToTheWhitelist($, account, status, data);
    }

    function _addAddressToTheWhitelist(WhitelistModuleInternalStorage storage $,address account, bool status, bytes memory /*data */) internal virtual{
        $._whitelisted[account] = status;
    }

    function _addAddressesToTheWhitelist(address[] calldata accounts, bool[] calldata status, bytes memory data) internal virtual{
        EnforcementModuleLibrary._checkInput(accounts, status);
        WhitelistModuleInternalStorage storage $ = _getWhitelistModuleInternalStorage();
        for (uint256 i = 0; i < accounts.length; ++i) {
            _addAddressToTheWhitelist($, accounts[i], status[i], data);
        }
    }

    /**
     * @dev Returns true if the account is frozen, and false otherwise.
     */
    function _addressIsWhitelisted(address account) internal view virtual returns (bool) {
        WhitelistModuleInternalStorage storage $ = _getWhitelistModuleInternalStorage();
        return $._whitelisted[account];
    }

        /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.WhitelistModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant WhitelistModuleInternalStorageLocation = 0x1c7bc8a17be064111d299d7669f49519cb26c58611b72d9f6ccc40a1e1184e00;
    
    

    /* ==== ERC-7201 State Variables === */
    struct WhitelistModuleInternalStorage {
        // not used if you don't use the WhitelistModule
        mapping(address => bool) _whitelisted;
    }

    /* ============ ERC-7201 ============ */
    function _getWhitelistModuleInternalStorage() internal pure returns (WhitelistModuleInternalStorage storage $) {
        assembly {
            $.slot := WhitelistModuleInternalStorageLocation
        }
    }
}
