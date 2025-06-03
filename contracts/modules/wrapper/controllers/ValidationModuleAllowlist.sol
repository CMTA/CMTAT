//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ValidationModule} from "./ValidationModule.sol";
import {AllowlistModule} from "../options/AllowlistModule.sol";
/**
 * @dev Validation module.
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
    * @dev function used by canTransfer and operateOnTransfer
    * Block mint if the contract is deactivated (PauseModule) 
    * or if to is frozen
    */
    function _canMintBurnByModule(
        address target
    ) internal view virtual override returns (bool) {
        if(_isAllowlistEnabled() && !isAllowlisted(target)){
            return false;
        } else {
            return ValidationModule._canMintBurnByModule(target);
        }
    }

    /**
    * @dev function used by canTransfer and operateOnTransfer
    */
    function _canTransferGenericByModule(
        address spender,
        address from,
        address to
    ) internal view virtual override returns (bool) {
         if(_isAllowlistEnabled()){
            // Mint
            if(from == address(0)){
                return _canMintBurnByModule(to);
            } 
            // burn
            // Use forcedTransfer to burn tokens from a non-whitelsited address
            else if(to == address(0)){
                return _canMintBurnByModule(from);
            }
            else if ((spender != address(0) && !isAllowlisted(spender)) || !isAllowlisted(from) || !isAllowlisted(to)){
                return false;
            } 
         }
         return ValidationModule._canTransferGenericByModule(spender, from, to);
    }
}
