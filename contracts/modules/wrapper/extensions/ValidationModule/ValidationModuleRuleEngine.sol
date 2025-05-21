//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


/* ==== Engine === */
import {IRuleEngine} from "../../../../interfaces/engine/IRuleEngine.sol";

import {ValidationModuleCore} from "../../core/ValidationModuleCore.sol";
import {ValidationModuleRuleEngineInternal} from "../../../internal/ValidationModuleRuleEngineInternal.sol";
/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleRuleEngine is
    ValidationModuleCore,
    ValidationModuleRuleEngineInternal
{
    error CMTAT_ValidationModule_SameValue();
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
        return _canTransferFrom(spender, from, to, value);
    }


    /*
    * @notice set a RuleEngine
    * @param ruleEngine_ the call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function setRuleEngine(
        IRuleEngine ruleEngine_
    ) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
         require(ruleEngine_ != ruleEngine(), CMTAT_ValidationModule_SameValue());
        _setRuleEngine(ruleEngine_);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */

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
        if (!canTransferFrom(spender, from, to, value)){
            return false;
        } else{
            IRuleEngine ruleEngine_ = ruleEngine();
            if (address(ruleEngine_) != address(0)){
                return ruleEngine_.transferred(spender, from, to, value);
            }else {
                return true;
            }
        }
    }
}
