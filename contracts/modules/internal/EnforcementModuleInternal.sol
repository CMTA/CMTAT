//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
/* ==== Module === */
import {EnforcementModuleLibrary} from "./common/EnforcementModuleLibrary.sol";
/**
 * @dev Enforcement module internal.
 *
 * Allows the issuer to set an allowlist
 */
abstract contract EnforcementModuleInternal is
    Initializable,
    ContextUpgradeable
{
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.EnforcementModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant EnforcementModuleInternalStorageLocation = 0x0c7bc8a17be064111d299d7669f49519cb26c58611b72d9f6ccc40a1e1184e00;

    /* ==== ERC-7201 State Variables === */
    struct EnforcementModuleInternalStorage {
        mapping(address account => bool status)_list;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    function _addAddressToTheList(address account, bool status, bytes memory data) internal virtual{
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        _addAddressToTheList($, account, status, data);
    }

    function _addAddressToTheList(EnforcementModuleInternalStorage storage $,address account, bool status, bytes memory /*data */) internal virtual{
        $._list[account] = status;
    }

  function _addAddressesToTheList(address[] calldata accounts, bool[] calldata status, bytes memory data) internal virtual{
        EnforcementModuleLibrary._checkInput(accounts, status);
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        for (uint256 i = 0; i < accounts.length; ++i) {
            _addAddressToTheList($, accounts[i], status[i], data);
        }
    }

    /* ============ View functions ============ */
    /**
     * @dev Returns true if the account is frozen, and false otherwise.
     */
    function _addressIsListed(address account) internal view virtual returns (bool _isListed) {
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        return $._list[account];
    }

    /* ============ ERC-7201 ============ */
    function _getEnforcementModuleInternalStorage() internal pure returns (EnforcementModuleInternalStorage storage $) {
        assembly {
            $.slot := EnforcementModuleInternalStorageLocation
        }
    }
}
