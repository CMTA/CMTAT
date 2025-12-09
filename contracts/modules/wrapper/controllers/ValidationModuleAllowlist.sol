//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ValidationModule} from "./ValidationModule.sol";
import {AllowlistModule} from "../options/AllowlistModule.sol";
/**
 * @title ValidationModule - Allowlist
 * @dev Validation module with allowlist.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleAllowlist is
    AllowlistModule, ValidationModule
{
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
    * @dev Use forcedTransfer (or forcedBurn) to burn tokens from an non-allowlist address
    */
    function _canMintBurnByModule(
        address target
    ) internal view virtual override(ValidationModule) returns (bool) {
        if(_isAllowlistEnabled() && !isAllowlisted(target)){
            return false;
        } else {
            return ValidationModule._canMintBurnByModule(target);
        }
    }

    /**
    * @dev Add allowlist check for standard transfer
    */
    function _canTransferStandardByModule(
        address spender,
        address from,
        address to
    ) internal view virtual override(ValidationModule) returns (bool) {
        if(_isAllowlistEnabled()){
            bool spenderCheck = spender != address(0) && !isAllowlisted(spender);
            if (spenderCheck || !isAllowlisted(from) || !isAllowlisted(to)){
                return false;
            }
        }
        return ValidationModule._canTransferStandardByModule(spender, from, to);
    }
}
