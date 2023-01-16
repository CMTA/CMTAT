//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../optional/AuthorizationModule.sol";
import "../../internal/EnforcementModuleInternal.sol";

/**
 * @dev Enforcement module.
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract EnforcementModule is EnforcementModuleInternal,
    AuthorizationModule {

    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
    string internal constant TEXT_TRANSFER_REJECTED_FROZEN =
        "The address is frozen";

    function __EnforcementModule_init() internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        
        /* Internal */
        __Enforcement_init_unchained();
        
        /* Wrapper */
        __AuthorizationModule_init_unchained();

        /* own function */
        __EnforcementModule_init_unchained();
    }

    function __EnforcementModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @notice Freezes an address.
     * @param account the account to freeze
     * @param reason indicate why the account was frozen. 
     */
    function freeze(address account, string memory reason)
        public
        onlyRole(ENFORCER_ROLE)
        returns (bool)
    {
        return _freeze(account, reason);
    }

    /**
     * @notice Unfreezes an address.
     * @param account the account to unfreeze
     * @param reason indicate why the account was unfrozen. 
     *  
     *
     */
    function unfreeze(address account, string memory reason)
        public
        onlyRole(ENFORCER_ROLE)
        returns (bool)
    {
        return _unfreeze(account, reason);
    }

    uint256[50] private __gap;
}
