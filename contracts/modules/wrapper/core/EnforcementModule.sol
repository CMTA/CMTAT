//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../security/AuthorizationModule.sol";
import "../../internal/EnforcementModuleInternal.sol";

/**
 * @dev Enforcement module.
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract EnforcementModule is
    EnforcementModuleInternal,
    AuthorizationModule
{
    // EnforcementModule
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
    string internal constant TEXT_TRANSFER_REJECTED_FROM_FROZEN =
        "Address FROM is frozen";

    string internal constant TEXT_TRANSFER_REJECTED_TO_FROZEN =
        "Address TO is frozen";

    function __EnforcementModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

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

    uint256[50] private __gap;
}
