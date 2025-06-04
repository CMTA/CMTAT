//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {EnforcementModuleInternal} from "../../internal/EnforcementModuleInternal.sol";
import {IERC3643Enforcement, IERC3643EnforcementEvent} from "../../../interfaces/tokenization/IERC3643Partial.sol";
/*
/**
 * @title Enforcement module.
 * @dev 
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract EnforcementModule is
    EnforcementModuleInternal,
    AuthorizationModule,
    IERC3643Enforcement,
    IERC3643EnforcementEvent
{
    /* ============ State Variables ============ */
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
    * @inheritdoc IERC3643Enforcement
    */
    function isFrozen(address account) public override(IERC3643Enforcement) view virtual returns (bool) {
       return _addressIsListed(account);
       
    }

    /**
    * @inheritdoc IERC3643Enforcement
    */
    function setAddressFrozen(address account, bool freeze) public virtual override(IERC3643Enforcement) onlyRole(ENFORCER_ROLE){
         _addAddressToTheList(account, freeze, "");
    }

    /**
     * @notice Freezes/unfreeze an address.
     * @param account the account to freeze
     * @param freeze true to freeze, false to unfreeze
     * @param data indicate why the account was frozen.
     */
    function setAddressFrozen(
        address account, bool freeze, bytes calldata data
    ) public virtual onlyRole(ENFORCER_ROLE)  {
         _addAddressToTheList(account, freeze, data);
    }

    /**
    * @notice batch version of {setAddressFrozen}
    */
    function batchSetAddressFrozen(
        address[] calldata accounts, bool[] calldata freezes
    ) public virtual override(IERC3643Enforcement) onlyRole(ENFORCER_ROLE) {
         _addAddressesToTheList(accounts, freezes, "");
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _addAddressToTheList(EnforcementModuleInternalStorage storage $,address account, bool freeze, bytes memory data) internal override(EnforcementModuleInternal){
        EnforcementModuleInternal._addAddressToTheList($, account, freeze, data);
        emit AddressFrozen(account, freeze, _msgSender(), data);
    }
}
