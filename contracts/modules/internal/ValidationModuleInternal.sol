//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
/* ==== Tokenization === */
import {IERC3643ComplianceRead} from "../../interfaces/tokenization/IERC3643Partial.sol";
/* ==== Engine === */
import {IRuleEngine} from "../../interfaces/engine/IRuleEngine.sol";

import {ValidationModuleInternalCore} from "./ValidationModuleInternalCore.sol";
/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleInternal is
    Initializable,
    ContextUpgradeable,
    ValidationModuleInternalCore
{
    error CMTAT_ValidationModule_SameValue();

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

/* ============ Transfer & TransferFrom ============ */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view virtual override(ValidationModuleInternalCore) returns (bool) {
        if (!ValidationModuleInternalCore.canTransfer(from, to, value)) {
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
    ) public view virtual override(ValidationModuleInternalCore) returns (bool) {
        if (!ValidationModuleInternalCore.canTransferFrom(spender, from, to, value)) {
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
