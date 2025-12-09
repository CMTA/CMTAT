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

    function _canMintBurnByModuleAndRevert(
        address target
    ) internal view virtual override(ValidationModule) returns (bool) {

        if(_isAllowlistEnabled() && !isAllowlisted(target)){
            revert ERC7943CannotTransact(target);
        } else {
            return ValidationModule._canMintBurnByModuleAndRevert(target);
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

    function _canTransferStandardByModuleAllowlistAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        address target;
        if (spender != address(0) && !isAllowlisted(spender)){
            target = spender;
        } else if (!isAllowlisted(from)) {
            target = from;
        } else if(!isAllowlisted(to) ){
            target = to;
        } else {
            return true;
        }
        revert ERC7943CannotTransact(target);
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
}
