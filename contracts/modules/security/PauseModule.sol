//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "./AuthorizationModule.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract PauseModule is PausableUpgradeable, AuthorizationModule {
    string internal constant TEXT_TRANSFER_REJECTED_PAUSED =
        "All transfers paused";
    bool  isDeactivated;
    event Deactivated(address account);

    function __PauseModule_init(address admin) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        __Pausable_init_unchained();
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();

        /* CMTAT modules */
        // Security
        __AuthorizationModule_init_unchained(admin);

        // own function
        __PauseModule_init_unchained();
    }

    function __PauseModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public onlyRole(PAUSER_ROLE) {
        if(isDeactivated){
            revert Errors.CMTAT_PauseModule_ContractIsDeactivated();
        }
        _unpause();
    }

        /**
    @notice destroys the contract and send the remaining ethers in the contract to the sender
    Warning: the operation is irreversible, be careful
    */
    /// @custom:oz-upgrades-unsafe-allow selfdestruct
    function deactivateContract()
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        isDeactivated = true;
       _pause();
       emit Deactivated(_msgSender());
    }

    uint256[50] private __gap;
}
