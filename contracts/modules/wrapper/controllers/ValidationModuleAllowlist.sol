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
        address account
    ) internal view virtual override(ValidationModule) returns (bool) {
        if(_isAllowlistEnabled() && !isAllowlisted(account)){
            return false;
        } else {
            return ValidationModule._canMintBurnByModule(account);
        }
    }

    /**
    * @dev Add allowlist check for standard transfer
    */
    function _canTransferStandardByModuleAllowlist(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        if(_isAllowlistEnabled()){
            bool spenderCheck = spender != address(0) && !isAllowlisted(spender);
            if (spenderCheck || !isAllowlisted(from) || !isAllowlisted(to)){
                return true;
            }
        }
       return false;
    }

    /**
    * @dev Add allowlist check for standard transfer
    */
    function _canTransferStandardByModule(
        address spender,
        address from,
        address to
    ) internal view virtual override(ValidationModule) returns (bool) {
        if(_canTransferStandardByModuleAllowlist(spender, from, to)){
           return false;
        }
        return ValidationModule._canTransferStandardByModule(spender, from, to);
    }

    function _canTransact(address account) internal view virtual override(ValidationModule) returns (bool allowed) {
        if(_isAllowlistEnabled() && !isAllowlisted(account)){
            return false;
        } else {
            return ValidationModule._canTransact(account);
        }
    }

    /* ============ View functions which revert ============ */
    function _canMintBurnByModuleAndRevert(
        address account
    ) internal view virtual override(ValidationModule) returns (bool) {
        if(_isAllowlistEnabled() && !isAllowlisted(account)){
            revert ERC7943CannotTransact(account);
        } else {
            return ValidationModule._canMintBurnByModuleAndRevert(account);
        }
    }

    function _canTransferStandardByModuleAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual override(ValidationModule) returns (bool) {
        _canTransferStandardByModuleAllowlistAndRevert(spender, from, to);
        return ValidationModule._canTransferStandardByModuleAndRevert(spender, from, to);
    }

    function _canTransferStandardByModuleAllowlistAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual {
        address account;
        if(_isAllowlistEnabled()){
            if (spender != address(0) && !isAllowlisted(spender)){
                account = spender;
            } else if (!isAllowlisted(from)) {
                account = from;
            } else if(!isAllowlisted(to) ){
                account = to;
            } else {
               return;
            }
            // Will revert if the last else branch has not be taken
            revert ERC7943CannotTransact(account);
        }
    }
}
