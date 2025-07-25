//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {PauseModule}  from "../core/PauseModule.sol";
import {EnforcementModule} from "../core/EnforcementModule.sol";
/**
 * @title Validation module
 * @dev 
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is
    PauseModule,
    EnforcementModule
{
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
    * @dev check if the contract is deactivated or the address is frozen
    * check relevant for mint and burn operations
    */ 
    function _canMintBurnByModule(
        address target
    ) internal view virtual returns (bool) {
        if(PauseModule.deactivated() || EnforcementModule.isFrozen(target)){
            // can not mint or burn if the contract is deactivated
            // cannot burn if target is frozen (used forcedTransfer instead if available)
            // cannot mint if target is frozen
            return false;
        }
        return true;
    }

    /**
    * @dev calls Pause and Enforcement module
    */
    function _canTransferGenericByModule(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        // Mint
        if(from == address(0)){
            return _canMintBurnByModule(to);
        } // burn
        else if(to == address(0)){
            return _canMintBurnByModule(from);
        } // Normal transfer
        else if (EnforcementModule.isFrozen(spender) 
        || EnforcementModule.isFrozen(from) 
        || EnforcementModule.isFrozen(to) 
        || PauseModule.paused())  {
            return false;
        } else {
             return true;
        }
    }
}
