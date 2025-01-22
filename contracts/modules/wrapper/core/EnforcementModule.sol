//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {ERC20EnforcementModuleInternal} from "../../internal/ERC20EnforcementModuleInternal.sol";

/**
 * @title Enforcement module.
 * @dev 
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract EnforcementModule is
    ERC20EnforcementModuleInternal,
    AuthorizationModule
{
    /* ============ State Variables ============ */
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
    bytes32 public constant ENFORCER_ROLE_TRANSFER = keccak256("ENFORCER_ROLE_TRANSFER");
    string internal constant TEXT_TRANSFER_REJECTED_FROM_FROZEN =
        "Address FROM is frozen";

    string internal constant TEXT_TRANSFER_REJECTED_TO_FROZEN =
        "Address TO is frozen";

    /* ============  Initializer Function ============ */
    function __EnforcementModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Freezes an address.
     * @param account the account to freeze
     * @param reason indicate why the account was frozen.
     */
    function freeze(
        address account,
        string calldata reason
    ) public onlyRole(ENFORCER_ROLE) returns (bool) {
        return _freeze(account, reason);
    }

    /**
     * @notice Unfreezes an address.
     * @param account the account to unfreeze
     * @param reason indicate why the account was unfrozen.
     *
     *
     */
    function unfreeze(
        address account,
        string calldata reason
    ) public onlyRole(ENFORCER_ROLE) returns (bool) {
        return _unfreeze(account, reason);
    }


    /**
    * @notice Triggers a forced transfer.
    *
    */
  function enforceTransfer(address account, address destination, uint256 value, string calldata reason) public onlyRole(ENFORCER_ROLE_TRANSFER) {
        _enforceTransfer(account, destination, value, reason);
  }

}
