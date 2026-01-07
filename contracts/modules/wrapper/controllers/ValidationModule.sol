//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {PauseModule}  from "../core/PauseModule.sol";
import {EnforcementModule} from "../core/EnforcementModule.sol";
import {IERC7943TransactError} from "../../../interfaces/tokenization/draft-IERC7943.sol";
import {IERC7943FungibleTransactCheck} from "../../../interfaces/tokenization/draft-IERC7943.sol";
/**
 * @title Validation module
 * @dev 
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is
    PauseModule,
    EnforcementModule,
    IERC7943TransactError,
    IERC7943FungibleTransactCheck
{

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function canTransact(address account) public view virtual override(IERC7943FungibleTransactCheck) returns (bool allowed) {
        return _canTransact(account);
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
    * @dev 
    * Entrypoint to check mint/burn/standard transfer
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
        } // Standard transfer
        else {
            return _canTransferStandardByModule(spender, from, to);
        }
    }

    function _canTransferGenericByModuleAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        // Mint
        if(from == address(0)){
            return _canMintBurnByModuleAndRevert(to);
        } // burn
        else if(to == address(0)){
            return _canMintBurnByModuleAndRevert(from);
        } // Standard transfer
        else {
            return _canTransferStandardByModuleAndRevert(spender, from, to);
        }
    }

    /**
    * @dev check if the contract is deactivated or the address is frozen
    * check relevant for mint and burn operations
    * Use forcedTransfer (or forcedBurn) to burn tokens from a frozen address
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
    * @dev check if the contract is deactivated or the address is frozen
    * check relevant for mint and burn operations
    * Use forcedTransfer (or forcedBurn) to burn tokens from a frozen address
    */ 
    function _canMintBurnByModuleAndRevert(
        address target
    ) internal view virtual returns (bool) {
        if(PauseModule.deactivated()){
            // can not mint or burn if the contract is deactivated
            revert EnforcedDeactivation();
        }
        // cannot burn if target is frozen (used forcedTransfer instead if available)
        // cannot mint if target is frozen
        if(EnforcementModule.isFrozen(target)){
            revert ERC7943CannotTransact(target);
        }
        return true;
    }

    /**
    * @dev calls Pause and Enforcement module
    * check relevant for standard transfer
    * We don't check deactivated() because the contract must be in the pause state to be deactivated
    */
    function _canTransferisFrozen(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        if (EnforcementModule.isFrozen(spender) 
        || EnforcementModule.isFrozen(from) 
        || EnforcementModule.isFrozen(to) ){
            return true;
        } else {
             return false;
        }
    }

    function _canTransferisFrozenAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        address target;
        if (EnforcementModule.isFrozen(spender)){
            target = spender;
        } else if (EnforcementModule.isFrozen(from)) {
            target = from;
        } else if(EnforcementModule.isFrozen(to) ){
            target = to;
        } else {
            return true;
        }
        revert ERC7943CannotTransact(target);
    }

  function _canTransferStandardByModule(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        if (_canTransferisFrozen(spender, from, to)
        || PauseModule.paused())  {
            return false;
        } else {
             return true;
        }
    }

    function _canTransferStandardByModuleAndRevert(
        address spender,
        address from,
        address to
    ) internal view virtual returns (bool) {
        /**
         * We don't check the deactivate status because
         * the contract will be in the pause state if deactivated
         * This remove a supplementary check and reduce runtime gas sot
         */
        _requireNotPaused();
        _canTransferisFrozenAndRevert(spender, from, to);
        return true;
    }


    /** 
    * @notice Checks if a specific account is allowed to transact according to token rules.
    * @dev This is often used for allowlist/KYC/KYB/AML checks.
    * @param account The address to check.
    * @return allowed True if the account is allowed, false otherwise.
    */
    function _canTransact(address account) internal view virtual returns (bool allowed) {
        if(EnforcementModule.isFrozen(account)) {
            return false;
        } else {
            return true;
        }
    }
}
