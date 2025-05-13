//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Enforcement module.
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract EnforcementModuleInternal is
    Initializable,
    ContextUpgradeable
{
    error CMTAT_EnforcementModuleInternal_EmptyAccounts();
    error CMTAT_EnforcementModuleInternal_AccountsValueslengthMismatch();
    
     /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.EnforcementModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant EnforcementModuleInternalStorageLocation = 0x3f8bb8b8091c756b4423e8d10de8c6b7534e765f399b3f3409d2bed57af75e00;
    

    /* ==== ERC-7201 State Variables === */
    struct EnforcementModuleInternalStorage {
        mapping(address => bool) _frozen;
    }


    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    function __Enforcement_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _addAddressToTheList(address account, bool freeze, bytes memory data) internal virtual{
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        _addAddressToTheList($, account, freeze, data);
    }

    function _addAddressToTheList(EnforcementModuleInternalStorage storage $,address account, bool freeze, bytes memory /*data */) internal virtual{
        $._frozen[account] = freeze;
    }



  function _addAddressesToTheList(address[] calldata accounts, bool[] calldata freezes, bytes memory data) internal virtual{
        require(accounts.length > 0, CMTAT_EnforcementModuleInternal_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == freezes.length), CMTAT_EnforcementModuleInternal_AccountsValueslengthMismatch());
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        for (uint256 i = 0; i < accounts.length; ++i) {
            _addAddressToTheList($, accounts[i], freezes[i], data);
        }
    }

    /**
     * @dev Returns true if the account is frozen, and false otherwise.
     */
    function _addressIsListed(address account) internal view virtual returns (bool) {
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        return $._frozen[account];
    }

    /* ============ ERC-7201 ============ */
    function _getEnforcementModuleInternalStorage() private pure returns (EnforcementModuleInternalStorage storage $) {
        assembly {
            $.slot := EnforcementModuleInternalStorageLocation
        }
    }
}
