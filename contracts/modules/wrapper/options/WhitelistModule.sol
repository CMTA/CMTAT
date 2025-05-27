//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {WhitelistModuleInternal} from "../../internal/WhitelistModuleInternal.sol";

/*
/**
 * @title Enforcement module.
 * @dev 
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract WhitelistModule is
    WhitelistModuleInternal,
    AuthorizationModule
{
    event AddressWhitelisted(address indexed account, bool indexed status, address indexed enforcer, bytes data);
    /* ============ State Variables ============ */
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
   
    
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
 
    function isWhitelisted(address account) public view virtual returns (bool) {
       return _addressIsWhitelisted(account);
    }


    function setAddressWhitelisted(address account, bool status) public virtual  onlyRole(WHITELIST_ROLE){
         _addAddressToTheWhitelist(account, status, "");
    }

    /**
     * @notice Freezes/unfreeze an address.
     * @param account the account to freeze
     * @param status true to freeze, false to unfreeze
     * @param data further information if needed
     */
    function setAddressWhitelisted(
        address account, bool status, bytes calldata data
    ) public virtual onlyRole(WHITELIST_ROLE)  {
         _addAddressToTheWhitelist(account, status, data);
    }

    /**
    * @notice batch version of {setAddressFrozen}
    */
    function batchSetAddressWhitelisted(
        address[] calldata accounts, bool[] calldata status
    ) public virtual onlyRole(WHITELIST_ROLE) {
         _addAddressesToTheWhitelist(accounts, status, "");
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _addAddressToTheWhitelist(WhitelistModuleInternalStorage storage $,address account, bool status, bytes memory data) internal override(WhitelistModuleInternal){
        WhitelistModuleInternal._addAddressToTheWhitelist($, account, status, data);
        emit AddressWhitelisted(account, status, _msgSender(), data);
    } 
}
