// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {IAllowlistModule} from "../../../interfaces/modules/IAllowlistModule.sol";
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
    IAllowlistModule
{
    /* ============ State Variables ============ */
    bytes32 public constant ALLOWLIST_ROLE = keccak256("ALLOWLIST_ROLE");
   
    /* ============ Modifier ============ */
    modifier onlyAllowlistManager {
        _authorizeAllowlistManagement();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State functions ============ */
    /** 
    * @inheritdoc IAllowlistModule
    */
    function setAddressAllowlist(address account, bool status) public virtual onlyAllowlistManager{
         _addToAllowlist(account, status, "");
    }


    /** 
    * @inheritdoc IAllowlistModule
    */
    function setAddressAllowlist(
        address account, bool status, bytes calldata data
    ) public virtual onlyAllowlistManager {
         _addToAllowlist(account, status, data);
    }


    /** 
    * @inheritdoc IAllowlistModule
    */
    function batchSetAddressAllowlist(
        address[] calldata accounts, bool[] calldata status
    ) public virtual onlyAllowlistManager {
         _addToAllowlist(accounts, status, "");
    }


    /** 
    * @inheritdoc IAllowlistModule
    */
    function enableAllowlist(
        bool status
    ) public virtual onlyAllowlistManager {
        _enableAllowlist(status);
        emit AllowlistEnableStatus(_msgSender(), status);
    }

    /* ============ View functions ============ */

    /** 
    * @inheritdoc IAllowlistModule
    */
    function isAllowlistEnabled() public view virtual returns (bool) {
        return _isAllowlistEnabled();
    }

    /** 
    * @inheritdoc IAllowlistModule
    */
    function isAllowlisted(address account) public view virtual returns (bool) {
       return _isAllowlisted(account);
    }
    
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _addToAllowlist(AllowlistModuleInternalStorage storage $,address account, bool status, bytes memory data) internal override(AllowlistModuleInternal){
        AllowlistModuleInternal._addToAllowlist($, account, status, data);
        emit AddressAddedToAllowlist(account, status, _msgSender(), data);
    } 

    /* ==== Access Control ==== */
    function _authorizeAllowlistManagement() internal virtual;
}
