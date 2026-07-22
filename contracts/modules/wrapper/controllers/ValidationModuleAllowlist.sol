// SPDX-License-Identifier: MPL-2.0

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
    * @return True if the mint/burn is allowed (allowlist check plus the base checks).
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
    * @return True if the allowlist blocks the transfer (allowlist enabled and a party is not allowlisted).
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
    * @return True if the standard transfer is allowed (passes the allowlist and base checks).
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

    /// @inheritdoc ValidationModule
    function _canSend(address account) internal view virtual override(ValidationModule) returns (bool allowed) {
        if(_isAllowlistEnabled() && !isAllowlisted(account)){
            return false;
        } else {
            return ValidationModule._canSend(account);
        }
    }

    /// @inheritdoc ValidationModule
    function _canReceive(address account) internal view virtual override(ValidationModule) returns (bool allowed) {
        if(_isAllowlistEnabled() && !isAllowlisted(account)){
            return false;
        } else {
            return ValidationModule._canReceive(account);
        }
    }

    /* ============ View functions which revert ============ */
    /// @inheritdoc ValidationModule
    function _canMintByModuleAndRevert(
        address to
    ) internal view virtual override(ValidationModule) {
        if(_isAllowlistEnabled() && !isAllowlisted(to)){
            revert ERC7943CannotReceive(to);
        } else {
            ValidationModule._canMintByModuleAndRevert(to);
        }
    }

    /// @inheritdoc ValidationModule
    function _canBurnByModuleAndRevert(
        address from
    ) internal view virtual override(ValidationModule) {
        if(_isAllowlistEnabled() && !isAllowlisted(from)){
            revert ERC7943CannotSend(from);
        } else {
            ValidationModule._canBurnByModuleAndRevert(from);
        }
    }

    function _canTransferStandardByModuleAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual override(ValidationModule) {
        _canTransferStandardByModuleAllowlistAndRevert(spender, from, to);
        ValidationModule._canTransferStandardByModuleAndRevert(spender, from, to);
    }

    function _canTransferStandardByModuleAllowlistAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual {
        if(_isAllowlistEnabled()){
            if (spender != address(0) && !isAllowlisted(spender)){
                revert ERC7943CannotSend(spender);
            } else if (!isAllowlisted(from)) {
                revert ERC7943CannotSend(from);
            } else if(!isAllowlisted(to)){
                revert ERC7943CannotReceive(to);
            }
        }
    }
}
