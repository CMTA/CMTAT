//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {PauseModule}  from "../core/PauseModule.sol";
import {EnforcementModule} from "../core/EnforcementModule.sol";
/* ==== Tokenization === */
import {IERC3643ComplianceRead} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "../../../interfaces/tokenization/draft-IERC7551.sol";
/* ==== Engine === */
import {IRuleEngine} from "../../../interfaces/engine/IRuleEngine.sol";
/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleCore is
    PauseModule,
    EnforcementModule,
    IERC3643ComplianceRead,
    IERC7551Compliance
{
    function canMint(
        address to,
        uint256 /*value*/
    ) public virtual view returns (bool) {
        return _canMintByModule(to);
    }


    function canBurn(
        address /* from */,
        uint256 /* value */
    ) public virtual view returns (bool) {
        return _canBurnByModule();
    }

    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view virtual override(IERC3643ComplianceRead, IERC7551Compliance) returns (bool) {
        return _canTransferByModule(address(0), from, to, value);
    }

    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view virtual returns (bool) {
        return _canTransferByModule(spender, from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
    * @dev function used by canTransfer and operateOnTransfer
    * Block mint if the contract is deactivated (PauseModule) 
    * or if to is frozen
    */
    function _canMintByModule(
        address to
    ) internal view virtual returns (bool) {
        if(PauseModule.deactivated()){
            // can not mint or burn if the contract is deactivated
            return false;
        }
        if( isFrozen(to) ){
            return false;
        }
        return true;
    }


    /**
    * @dev function used by canTransfer and operateOnTransfer
    * Block burn if the contract is deactivated (PauseModule) 
    * Contrary to `_canMintByModule`, 
    * this function does not return false if from or to is frozen.
    * An issuer should be able to burn token from a frozen address.
    */
    function _canBurnByModule() internal view virtual returns (bool) {
        if(PauseModule.deactivated()){
            // can not mint or burn if the contract is deactivated
            return false;
        }
        return true;
    }

    /**
    @dev function used by canTransfer and operateOnTransfer
     */
    function _canTransferByModule(
        address spender,
        address from,
        address to,
        uint256 /*value*/
    ) internal view virtual returns (bool) {
        // Mint
        if(from == address(0)){
            return _canMintByModule(from);
        } // burn
        else if(to == address(0)){
            return _canBurnByModule();
        } // Normal transfer
        else if (EnforcementModule.isFrozen(spender) || EnforcementModule.isFrozen(from) || EnforcementModule.isFrozen(to) || PauseModule.paused())  {
            return false;
        } else {
             return true;
        }
    }
}
