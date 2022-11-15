//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "./AuthorizationModule.sol";
import "../internal/EnforcementModuleInternal.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract EnforcementModule is EnforcementModuleInternal,
    AuthorizationModule {

    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
    string internal constant TEXT_TRANSFER_REJECTED_FROZEN =
        "The address is frozen";

    /**
     * @dev Freezes an address.
     *
     */
    function freeze(address account)
        public
        onlyRole(ENFORCER_ROLE)
        returns (bool)
    {
        return _freeze(account);
    }

    /**
     * @dev Unfreezes an address.
     *
     */
    function unfreeze(address account)
        public
        onlyRole(ENFORCER_ROLE)
        returns (bool)
    {
        return _unfreeze(account);
    }
}
