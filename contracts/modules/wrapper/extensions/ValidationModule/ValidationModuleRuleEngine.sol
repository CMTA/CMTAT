//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


/* ==== Engine === */
import {IRuleEngine} from "../../../../interfaces/engine/IRuleEngine.sol";
/* ==== ValidationModule === */
import {ValidationModuleCore} from "../../core/ValidationModuleCore.sol";
import {ValidationModuleRuleEngineInternal} from "../../../internal/ValidationModuleRuleEngineInternal.sol";
/**
 * @dev Validation module with RuleEngine
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleRuleEngine is
    ValidationModuleCore,
    ValidationModuleRuleEngineInternal
{
    /**
    * @notice Reverts if attempting to set the RuleEngine to its current value.
    */
    error CMTAT_ValidationModule_SameValue();

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State functions ============ */
    /**
    * @notice Updates the RuleEngine used for validation/compliance transfer logic.
    * @dev Reverts with `CMTAT_ValidationModule_SameValue` if the new RuleEngine is the same as the current one.
    * Requirements:
    * - Caller must have `DEFAULT_ADMIN_ROLE`.
    * Emits a {RuleEngine} event.
    * @param ruleEngine_ The new RuleEngine contract to set.
    * @custom:access-control
    * - The caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function setRuleEngine(
        IRuleEngine ruleEngine_
    ) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
         require(ruleEngine_ != ruleEngine(), CMTAT_ValidationModule_SameValue());
        _setRuleEngine(ruleEngine_);
    }
    /* ============ View functions ============ */
    /**
    * @inheritdoc ValidationModuleCore
    * @dev call the ruleEngine if set
    */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view virtual override(ValidationModuleCore) returns (bool) {
       return _canTransfer(from, to, value);
    }

    /**
    * @inheritdoc ValidationModuleCore
    * @dev call the ruleEngine if set
    */
    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual override(ValidationModuleCore) returns (bool) {
        return _canTransferFrom(spender, from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    function _canTransfer(
        address from,
        address to,
        uint256 value)
    internal view virtual returns (bool) {
       if (!ValidationModuleCore.canTransfer(from, to, value)) {
            return false;
        } else {
            return _canTransferWithRuleEngine(from, to, value);
        }
    }

    function _canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        if (!ValidationModuleCore.canTransferFrom(spender, from, to, value)) {
            return false;
        } else {
            return _canTransferFromWithRuleEngine(spender, from, to, value);
        }
    }

    function _canTransferFromWithRuleEngine(
        address spender,
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        IRuleEngine ruleEngine_ = ruleEngine();
        if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.canTransferFrom(spender, from, to, value);
        } else{
            return true;
        }
    }
    function _canTransferWithRuleEngine(
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        IRuleEngine ruleEngine_ = ruleEngine();
        if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.canTransfer(from, to, value);
        } else{
            return true;
        }
    }

    /* ============ State functions ============ */
    function _transferred(address spender, address from, address to, uint256 value) internal virtual returns (bool){
        if(!_canTransferGenericByModule(spender, from, to)){
            return false;
        } else {
             IRuleEngine ruleEngine_ = ruleEngine();
             if (address(ruleEngine_) != address(0)){
                 if(spender != address(0)){
                    ruleEngine_.transferred(spender, from, to, value);
                  } else {
                     ruleEngine_.transferred(from, to, value);
                  }
            }
        }
        return true;
    }
}
