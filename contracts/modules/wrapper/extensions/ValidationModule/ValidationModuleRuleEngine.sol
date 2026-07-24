// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


/* ==== Engine === */
import {IRuleEngine} from "../../../../interfaces/engine/IRuleEngine.sol";
/* ==== ValidationModule === */
import {ValidationModuleAllowance} from "./ValidationModuleAllowance.sol";
import {ValidationModuleCore} from "../../core/ValidationModuleCore.sol";
import {ValidationModuleRuleEngineInternal} from "../../../internal/ValidationModuleRuleEngineInternal.sol";
/**
 * @dev Validation module with RuleEngine
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleRuleEngine is
    ValidationModuleAllowance,
    ValidationModuleRuleEngineInternal
{
    /**
    * @notice Reverts if attempting to set the RuleEngine to its current value.
    */
    error CMTAT_ValidationModule_SameValue();


    /* ============ Modifier ============ */
    modifier onlyRuleEngineManager() {
        _authorizeRuleEngineManagement();
        _;
    }

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
    ) public virtual onlyRuleEngineManager {
         require(address(ruleEngine_) != address(ruleEngine()), CMTAT_ValidationModule_SameValue());
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

    /* ============ Access Control ============ */
    function _authorizeRuleEngineManagement() internal virtual;

    /* ============ State functions ============ */
    /**
    * @dev
    * @custom:security The RuleEngine callback is the only point at which a transfer hands control
    * to an external contract, and it happens *before* the ERC-20 balances move: the active-balance
    * (frozen) check in {CMTATBaseCommon-_checkTransferred} has already run against the pre-transfer
    * state and is not re-evaluated afterwards. A RuleEngine that reenters the token during
    * `transferred(...)` — because it is malicious, compromised, or because one of its rules calls
    * untrusted code — is therefore validated twice against the same snapshot, and the outer and
    * inner transfers can together move more than the holder's unfrozen balance, breaking the
    * `frozenTokens <= balanceOf` invariant.
    *
    * The external call is isolated in {_callRuleEngineTransferred}, which is `virtual` so that a
    * deployment variant can wrap it in a reentrancy guard by inheriting
    * {ValidationModuleRuleEngineReentrancyGuard}.
    *
    * WARNING - the guard is **not** enabled on every variant. It costs ~187 bytes of deployed
    * bytecode, and several variants are within a few hundred bytes of the EIP-170 24 KiB limit, so
    * enabling it there would make them undeployable. Variants without the guard rely on the standard
    * CMTAT trust assumption: the RuleEngine is set by `DEFAULT_ADMIN_ROLE`, is fully trusted, and
    * MUST NOT hand control to untrusted code during `transferred(...)`. See the module documentation
    * for the per-variant table.
    *
    * The guard is entered only when a RuleEngine is set, so a deployment with no engine pays
    * nothing, and it is released when the callback returns, so sequential hooks (batch operations,
    * `burnAndMint`) are unaffected.
    */
    function _transferred(address spender, address from, address to, uint256 value) internal virtual{
        _canTransferGenericByModuleAndRevert(spender, from, to);
        IRuleEngine ruleEngine_ = ruleEngine();
        if (address(ruleEngine_) != address(0)){
            _callRuleEngineTransferred(ruleEngine_, spender, from, to, value);
        }
    }

    /**
    * @dev Performs the RuleEngine `transferred` call.
    *
    * Declared `virtual` so a deployment variant can wrap it in a reentrancy guard by overriding it
    * with {ValidationModuleRuleEngineReentrancyGuard}. The base implementation is **unguarded**: see
    * the security note on {_transferred} for which variants enable the guard and why it is not
    * enabled everywhere.
    */
    function _callRuleEngineTransferred(
        IRuleEngine ruleEngine_,
        address spender,
        address from,
        address to,
        uint256 value
    ) internal virtual {
        if(spender != address(0)){
            ruleEngine_.transferred(spender, from, to, value);
        } else {
            ruleEngine_.transferred(from, to, value);
        }
    }
}
