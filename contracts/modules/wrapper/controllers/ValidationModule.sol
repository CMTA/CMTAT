//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {PauseModule}  from "../core/PauseModule.sol";
import {EnforcementModule} from "../core/EnforcementModule.sol";
/* ==== Tokenization === */
import {IERC1404} from "../../../interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "../../../interfaces/tokenization/draft-IERC7551.sol";
/* ==== Engine === */
import {IRuleEngine} from "../../../interfaces/engine/IRuleEngine.sol";

import {ValidationModuleCore} from "./ValidationModuleCore.sol";
/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is
    Initializable,
    ContextUpgradeable,
    IERC1404,
    ValidationModuleCore
{
    error CMTAT_ValidationModule_SameValue();
    /* ============ State Variables ============ */
    string constant TEXT_TRANSFER_OK = "No restriction";
    string constant TEXT_UNKNOWN_CODE = "Unknown code";


    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event RuleEngine(IRuleEngine indexed newRuleEngine);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ValidationModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ValidationModuleInternalStorageLocation = 0xb3e8f29e401cfa802cad91001b5f9eb50decccdb111d80cb07177ab650b04700;
    /* ==== ERC-7201 State Variables === */
    struct ValidationModuleInternalStorage {
        IRuleEngine _ruleEngine;
    }

    /* ============  Initializer Function ============ */
    function __ValidationModule_init_unchained(
        IRuleEngine ruleEngine_
    ) internal onlyInitializing {
        if (address(ruleEngine_) != address(0)) {
            ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
            _setRuleEngine($, ruleEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function ruleEngine() public view returns(IRuleEngine){
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        return $._ruleEngine;
    }

    /*
    * @notice set a RuleEngine
    * @param ruleEngine_ the call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function setRuleEngine(
        IRuleEngine ruleEngine_
    ) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        require($._ruleEngine != ruleEngine_, CMTAT_ValidationModule_SameValue());
        _setRuleEngine($,ruleEngine_);
    }

    /**
     * @notice returns the human readable explaination 
     * corresponding to the error code returned by detectTransferRestriction
     * @param restrictionCode The error code returned by detectTransferRestriction
     * @return message The human readable explaination corresponding to the error code returned by detectTransferRestriction
     * @dev see {ERC-1404}
     */
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) public virtual view override(IERC1404) returns (string memory message) {
          ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (restrictionCode == uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_OK)) {
            return TEXT_TRANSFER_OK;
        } else if (
            restrictionCode ==
            uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED)
        ) {
            return TEXT_TRANSFER_REJECTED_PAUSED;
        } else if (
            restrictionCode ==
            uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_FROM_FROZEN;
        } else if (
            restrictionCode ==
            uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_TO_FROZEN;
        } else if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.messageForTransferRestriction(restrictionCode);
        } else {
            return TEXT_UNKNOWN_CODE;
        }
    }
    
    /**
     * @notice check if value token can be transferred from `from` to `to`
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     * @return code of the rejection reason
     * @dev see {ERC-1404}
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public virtual view override(IERC1404) returns (uint8 code) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (paused()) {
            return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED);
        } else if (isFrozen(from)) {
            return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN);
        } else if (isFrozen(to)) {
            return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN);
        } else if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.detectTransferRestriction(from, to, value);
        } 
        else {
            return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    /* ============ Mint & Burn ============ */
    /*function canMint(
        address to,
        uint256 value
    ) public virtual  override(ValidationModuleCore) view returns (bool) {
        if (!ValidationModuleCore.canMint(to, value)) {
            return false;
        } else {
            return _canTransferWithRuleEngine(address(0), to, value);
        }
    }*/


    /*function canBurn(
        address from,
        uint256 value
    ) public virtual override(ValidationModuleCore) view returns (bool) {
        if (!ValidationModuleCore.canBurn(from, value)) {
            return false;
        } else {
            return _canTransferWithRuleEngine(from, address(0), value);
        }
    }*/

/* ============ Transfer & TransferFrom ============ */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view virtual override(ValidationModuleCore) returns (bool) {
        if (!ValidationModuleCore.canTransfer(from, to, value)) {
            return false;
        } else {
            return _canTransferWithRuleEngine(from, to, value);
        }
    }

    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override(ValidationModuleCore) returns (bool) {
        if (!ValidationModuleCore.canTransferFrom(spender, from, to, value)) {
            return false;
        } else {
            return _canTransferFromWithRuleEngine(spender, from, to, value);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    function _canTransferFromWithRuleEngine(
        address spender,
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.canTransferFrom(spender, from, to, value);
        } else{
            return true;
        }
    }
    function _canTransferWithRuleEngine(
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.canTransfer(from, to, value);
        } else{
            return true;
        }
    }

    /* ============ State functions ============ */
    /*
    * @dev set a RuleEngine
    * @param ruleEngine_ 
    * The call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function _setRuleEngine(
        ValidationModuleInternalStorage storage $,
        IRuleEngine ruleEngine_
    )  internal virtual {
        $._ruleEngine = ruleEngine_;
        emit RuleEngine(ruleEngine_);
    }

    function _transferred(address spender, address from, address to, uint256 value) internal virtual returns (bool){
        if (!canTransferFrom(spender, from, to, value)){
            return false;
        } else{
            ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
            if (address($._ruleEngine) != address(0)){
                return $._ruleEngine.transferred(spender, from, to, value);
            }else {
                return true;
            }
        }
    }

    /* ============ ERC-7201 ============ */
    function _getValidationModuleInternalStorage() internal pure returns (ValidationModuleInternalStorage storage $) {
        assembly {
            $.slot := ValidationModuleInternalStorageLocation
        }
    }
}
