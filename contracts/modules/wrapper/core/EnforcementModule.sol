//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
/* ==== Module === */
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
    AccessControlUpgradeable,
    IERC3643Enforcement,
    IERC3643EnforcementEvent
{
    /* ============ State Variables ============ */
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State restricted functions ============ */
    /**
    * @inheritdoc ICMTATMandatory
    */
    function freeze(address account) public override(ICMTATMandatory) {
        setAddressFrozen(account, true);
    }

    /**
    * @inheritdoc ICMTATMandatory
    */
    function unfreeze(address account) public override(ICMTATMandatory){
        setAddressFrozen(account, false);
    }

    /**
    * @inheritdoc IERC3643Enforcement
    * @custom:access-control
    * - the caller must have the `ENFORCER_ROLE`.
    */
    function setAddressFrozen(address account, bool freeze) public virtual override(IERC3643Enforcement) onlyRole(ENFORCER_ROLE){
         _addAddressToTheList(account, freeze, "");
    }
    
    /**
    * @notice Sets the frozen status of a specific account.
    * @dev 
    * Extend ERC-3643 functions `setAddressFrozen` with a supplementary `data` parameter
    * - Freezing an account prevents it from transferring or receiving tokens depending on enforcement logic.
    * - Emits an `AddressFrozen` event.
    * @param account The address whose frozen status is being updated.
    * @param freeze Set to `true` to freeze the account, or `false` to unfreeze it.
    * @param data Optional metadata providing context or justification for the action (e.g. compliance reason).
    * @custom:access-control
    * - the caller must have the `ENFORCER_ROLE`.
    */
    function setAddressFrozen(
        address account, bool freeze, bytes calldata data
    ) public virtual onlyRole(ENFORCER_ROLE)  {
         _addAddressToTheList(account, freeze, data);
    }

    /**
    * @inheritdoc IERC3643Enforcement
    * @custom:access-control
    * - the caller must have the `ENFORCER_ROLE`.
    */
    function batchSetAddressFrozen(
        address[] calldata accounts, bool[] calldata freezes
    ) public virtual override(IERC3643Enforcement) onlyRole(ENFORCER_ROLE) {
         _addAddressesToTheList(accounts, freezes, "");
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc IERC3643Enforcement
    */
    function isFrozen(address account) public override(IERC3643Enforcement) view virtual returns (bool isFrozen_) {
       return _addressIsListed(account);
       
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _addAddressToTheList(EnforcementModuleInternalStorage storage $,address account, bool freeze, bytes memory data) internal override(EnforcementModuleInternal){
        EnforcementModuleInternal._addAddressToTheList($, account, freeze, data);
        emit AddressFrozen(account, freeze, _msgSender(), data);
    }
}
