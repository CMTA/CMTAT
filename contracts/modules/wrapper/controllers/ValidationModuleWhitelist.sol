//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ValidationModule} from "./ValidationModule.sol";
import {WhitelistModule} from "../options/WhitelistModule.sol";
/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleWhitelist is
    WhitelistModule, ValidationModule
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
        if(activateWhitelist && !isWhitelisted(target)){
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
         if(activateWhitelist){
            // Mint
            if(from == address(0)){
                return _canMintBurnByModule(to);
            } // burn
            else if(to == address(0)){
                return _canMintBurnByModule(from);
            }
            else if ((spender != address(0) && !isWhitelisted(spender)) || !isWhitelisted(from) || !isWhitelisted(to)){
                return false;
            } 
         }
         return ValidationModule._canTransferGenericByModule(spender, from, to);
    }
}
