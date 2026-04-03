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
     * Requirements:
     * - contract must not be paused.
     * - `owner` must be allowed to transact.
     * - `spender` must be allowed to transact.
     */
    function _canAuthorizeAllowanceByModuleAndRevert(
        address owner,
        address spender
    ) internal view virtual {
        _requireNotPaused();
        if (!_canTransact(owner)) {
            revert ERC7943CannotTransact(owner);
        }
        if (!_canTransact(spender)) {
            revert ERC7943CannotTransact(spender);
        }
    }
}
