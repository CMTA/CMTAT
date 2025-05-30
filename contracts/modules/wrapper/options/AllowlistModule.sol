//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {AllowlistModuleInternal} from "../../internal/AllowlistModuleInternal.sol";

/*
/**
 * @title Allowlist module.
 * @dev 
 *
 * Allows the issuer to set an allowlist
 */
abstract contract AllowlistModule is
    AllowlistModuleInternal,
    AuthorizationModule
{
    event AddressAddedToAllowlist(address indexed account, bool indexed status, address indexed enforcer, bytes data);
    /* ============ State Variables ============ */
    bytes32 public constant ALLOWLIST_ROLE = keccak256("ALLOWLIST_ROLE");
   
    
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function isAllowlisted(address account) public view virtual returns (bool) {
       return _isAllowlisted(account);
    }

    function setAddressAllowlist(address account, bool status) public virtual  onlyRole(ALLOWLIST_ROLE){
         _addToAllowlist(account, status, "");
    }

    /**
     * @notice add/remove an address to/from the allowlist
     * @param account the account to add
     * @param status true to freeze, false to unlist
     * @param data further information if needed
     */
    function setAddressAllowlist(
        address account, bool status, bytes calldata data
    ) public virtual onlyRole(ALLOWLIST_ROLE)  {
         _addToAllowlist(account, status, data);
    }

    /**
    * @notice batch version of {setAddressFrozen}
    */
    function batchSetAddressAllowlist(
        address[] calldata accounts, bool[] calldata status
    ) public virtual onlyRole(ALLOWLIST_ROLE) {
         _addToAllowlist(accounts, status, "");
    }

    /**
    * @notice enable/disable allowlist
    */
    function enableAllowlist(
        bool status
    ) public virtual onlyRole(ALLOWLIST_ROLE) {
        _enableAllowlist(status);
    }

    /**
     * @notice Returns true if the list is enabled, false otherwise
     */
    function isAllowlistEnabled() public view virtual returns (bool) {
        return _isAllowlistEnabled();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _addToAllowlist(AllowlistModuleInternalStorage storage $,address account, bool status, bytes memory data) internal override(AllowlistModuleInternal){
        AllowlistModuleInternal._addToAllowlist($, account, status, data);
        emit AddressAddedToAllowlist(account, status, _msgSender(), data);
    } 
}
