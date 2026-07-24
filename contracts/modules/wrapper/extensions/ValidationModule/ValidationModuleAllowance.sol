// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== ValidationModule === */
import {ValidationModuleCore} from "../../core/ValidationModuleCore.sol";

/**
 * @dev Validation module for allowance authorization (`approve` and `permit`).
 *
 * It validates the allowance domain (`owner` + `spender`) instead of
 * transfer semantics (`spender` + `from` + `to`).
 */
abstract contract ValidationModuleAllowance is ValidationModuleCore {
    /**
     * @dev Reverts when allowance authorization cannot be performed.
     *
     * Requirements (for `value > 0`):
     * - contract must not be paused.
     * - `owner` must be allowed to send (`canSend` returns true).
     * - `spender` must be allowed to send (`canSend` returns true).
     *
     * Setting an allowance to zero is a **revocation**, never a new grant: it can only
     * reduce what a spender may move. It is therefore always authorized, including while
     * the contract is paused or when `owner`/`spender` is frozen or off the allowlist.
     * Blocking it would leave a holder unable to sever ties with a compromised or
     * sanctioned spender for the whole duration of the restriction, and would make the
     * zero-first allowance mitigation documented on `approve` unusable exactly when it
     * matters. No value can move while the restriction holds, since `transferFrom` is
     * gated by the same checks.
     *
     * @param owner The account granting (or revoking) the allowance.
     * @param spender The account being granted (or revoked).
     * @param value The new allowance value; `0` means revocation.
     */
    function _canAuthorizeAllowanceByModuleAndRevert(
        address owner,
        address spender,
        uint256 value
    ) internal view virtual {
        // A revocation is always allowed
        if (value == 0) {
            return;
        }
        _requireNotPaused();
        if (!_canSend(owner)) {
            revert ERC7943CannotSend(owner);
        }
        if (!_canSend(spender)) {
            revert ERC7943CannotSend(spender);
        }
    }
}
