//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {PauseModule}  from "../core/PauseModule.sol";
import {EnforcementModule} from "../core/EnforcementModule.sol";
import {Errors} from "../../../libraries/Errors.sol";
import {IERC1404Wrapper} from "../../../interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol";
import {IRuleEngine} from "../../../interfaces/engine/IRuleEngine.sol";
/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is
    Initializable,
    ContextUpgradeable,
    PauseModule,
    EnforcementModule,
    IERC1404Wrapper
{
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
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if ($._ruleEngine == ruleEngine_){
             revert Errors.CMTAT_ValidationModule_SameValue();
        }
        _setRuleEngine($,ruleEngine_);
    }

    /**
     * @dev ERC1404 returns the human readable explaination corresponding to the error code returned by detectTransferRestriction
     * @param restrictionCode The error code returned by detectTransferRestriction
     * @return message The human readable explaination corresponding to the error code returned by detectTransferRestriction
     */
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) external view override returns (string memory message) {
          ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (restrictionCode == uint8(REJECTED_CODE_BASE.TRANSFER_OK)) {
            return TEXT_TRANSFER_OK;
        } else if (
            restrictionCode ==
            uint8(REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED)
        ) {
            return TEXT_TRANSFER_REJECTED_PAUSED;
        } else if (
            restrictionCode ==
            uint8(REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_FROM_FROZEN;
        } else if (
            restrictionCode ==
            uint8(REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_TO_FROZEN;
        } else if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.messageForTransferRestriction(restrictionCode);
        } else {
            return TEXT_UNKNOWN_CODE;
        }
    }
    
    /**
     * @dev ERC1404 check if _value token can be transferred from _from to _to
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     * @return code of the rejection reason
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 amount
    ) public view override returns (uint8 code) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (paused()) {
            return uint8(REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED);
        } else if (frozen(from)) {
            return uint8(REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN);
        } else if (frozen(to)) {
            return uint8(REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN);
        } else if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.detectTransferRestriction(from, to, amount);
        } 
        else {
            return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    function validateTransfer(
        address from,
        address to,
        uint256 amount
    ) public view override returns (bool) {
        if (!_validateTransferByModule(from, to, amount)) {
            return false;
        } else {
            return _validateTransfer(from, to, amount);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    function _validateTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view returns (bool) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.validateTransfer(from, to, amount);
        } else{
            return true;
        }
    }

    function _validateTransferByModule(
        address from,
        address to,
        uint256 /*amount*/
    ) internal view returns (bool) {
        if (paused() || frozen(from) || frozen(to)) {
            return false;
        } else{
            return true;
        }
        
    }

    /* ============ State functions ============ */
    /*
    * @dev set a RuleEngine
    * @param ruleEngine_ the call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function _setRuleEngine(
        ValidationModuleInternalStorage storage $,
        IRuleEngine ruleEngine_
    )  internal {
        $._ruleEngine = ruleEngine_;
        emit RuleEngine(ruleEngine_);
    }

    function _operateOnTransfer(address from, address to, uint256 amount) internal returns (bool){
        if (!_validateTransferByModule(from, to, amount)){
            return false;
        } else{
            ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
            if (address($._ruleEngine) != address(0)){
                return $._ruleEngine.operateOnTransfer(from, to, amount);
            }else{
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
