//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {EnforcementModuleInternal} from "../../internal/EnforcementModuleInternal.sol";
import {IERC3643Enforcement} from "../../../interfaces/tokenization/IERC3643Partial.sol";
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
    IERC3643Enforcement
{
    /* ============ State Variables ============ */
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
    string internal constant TEXT_TRANSFER_REJECTED_FROM_FROZEN =
        "Address FROM is frozen";

    string internal constant TEXT_TRANSFER_REJECTED_TO_FROZEN =
        "Address TO is frozen";

    /* ============  Initializer Function ============ */
    function __EnforcementModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
    * @inheritdoc IERC3643Enforcement
    */
    function isFrozen(address account) public override(IERC3643Enforcement) view virtual returns (bool) {
       return _isFrozen(account);
       
    }

    /**
    * @inheritdoc IERC3643Enforcement
    */
    function setAddressFrozen(address account, bool freeze) public virtual override(IERC3643Enforcement) onlyRole(ENFORCER_ROLE){
         _setAddressFrozen(account, freeze, "");
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
         _setAddressFrozen(account, freeze, data);
    }

    /**
    * @notice batch version of {setAddressFrozen}
    */
    function batchSetAddressFrozen(
        address[] calldata accounts, bool[] calldata freezes
    ) public virtual onlyRole(ENFORCER_ROLE) {
         _batchSetAddressFrozen(accounts, freezes, "");
    }

   /* function batchSetAddressFrozen(
        address[] calldata accounts, bool[] calldata freezes, bytes calldata data
    ) public virtual onlyRole(ENFORCER_ROLE) {
         _batchSetAddressFrozen(accounts, freezes, data);
    }*/
}
