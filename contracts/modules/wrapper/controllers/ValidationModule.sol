// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== Module === */
import {PauseModule}  from "../core/PauseModule.sol";
import {EnforcementModule} from "../core/EnforcementModule.sol";
import {IERC7943FungibleSendReceiveError, IERC7943FungibleSendReceiveCheck} from "../../../interfaces/tokenization/draft-IERC7943.sol";
/**
 * @title Validation module
 * @dev 
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is
    PauseModule,
    EnforcementModule,
    IERC7943FungibleSendReceiveError,
    IERC7943FungibleSendReceiveCheck
{

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /// @inheritdoc IERC7943FungibleSendReceiveCheck
    function canSend(address account) public view virtual override(IERC7943FungibleSendReceiveCheck) returns (bool allowed) {
        return _canSend(account);
    }

    /// @inheritdoc IERC7943FungibleSendReceiveCheck
    function canReceive(address account) public view virtual override(IERC7943FungibleSendReceiveCheck) returns (bool allowed) {
        return _canReceive(account);
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    /**
    * @dev
    * Entrypoint to check mint/burn/standard transfer
    * @param spender The address initiating the transfer (address(0) for a direct transfer).
    * @param from The address tokens move from (address(0) for a mint).
    * @param to The address tokens move to (address(0) for a burn).
    * @return True if the mint/burn/transfer is allowed by the pause and enforcement modules.
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
    ) internal view virtual {
        // Mint
        if(from == address(0)){
             _canMintByModuleAndRevert(to);
        } // burn
        else if(to == address(0)){
            _canBurnByModuleAndRevert(from);
        } // Standard transfer
        else {
             _canTransferStandardByModuleAndRevert(spender, from, to);
        }
    }

    /**
    * @dev check if the contract is deactivated or the address is frozen
    * check relevant for mint and burn operations
    * Use forcedTransfer (or forcedBurn) to burn tokens from a frozen address
    * @return True if the mint/burn is allowed (contract not deactivated and `target` not frozen).
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
    * @dev Reverts if mint is not allowed for `to`.
    * Checks deactivation and frozen status of the recipient.
    * @param to The recipient whose mint is being validated.
    */
    function _canMintByModuleAndRevert(
        address to
    ) internal view virtual {
        _requireNotDeactivated();
        if(EnforcementModule.isFrozen(to)){
            revert ERC7943CannotReceive(to);
        }
    }

    /**
    * @dev Reverts if burn is not allowed for `from`.
    * Checks deactivation and frozen status of the token holder.
    * @param from The holder whose burn is being validated.
    */
    function _canBurnByModuleAndRevert(
        address from
    ) internal view virtual {
        _requireNotDeactivated();
        if(EnforcementModule.isFrozen(from)){
            revert ERC7943CannotSend(from);
        }
    }

    /**
    * @dev calls Pause and Enforcement module
    * check relevant for standard transfer
    * We don't check deactivated() because the contract must be in the pause state to be deactivated
    * @param spender The address initiating the transfer.
    * @param from The address tokens move from.
    * @param to The address tokens move to.
    * @return True if any of `spender`, `from` or `to` is frozen.
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
    ) internal view virtual {
        if (EnforcementModule.isFrozen(spender)){
            revert ERC7943CannotSend(spender);
        } else if (EnforcementModule.isFrozen(from)) {
            revert ERC7943CannotSend(from);
        } else if(EnforcementModule.isFrozen(to) ){
            revert ERC7943CannotReceive(to);
        }
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
    ) internal view virtual{
        /**
         * We don't check the deactivate status because
         * the contract will be in the pause state if deactivated
         * This removes a supplementary check and reduces runtime gas cost
         */
        _requireNotPaused();
        _canTransferisFrozenAndRevert(spender, from, to);
    }


    /**
    * @dev Returns true if `account` is allowed to send tokens.
    * Base check: account must not be frozen.
    * Override in subclasses to add allowlist or other checks.
    * @param account The account being checked.
    * @return allowed True if `account` is allowed to send tokens.
    */
    function _canSend(address account) internal view virtual returns (bool allowed) {
        return !EnforcementModule.isFrozen(account);
    }

    /**
    * @dev Returns true if `account` is allowed to receive tokens.
    * Base check: account must not be frozen.
    * Override in subclasses to add allowlist or other checks.
    * @param account The account being checked.
    * @return allowed True if `account` is allowed to receive tokens.
    */
    function _canReceive(address account) internal view virtual returns (bool allowed) {
        return !EnforcementModule.isFrozen(account);
    }
}
