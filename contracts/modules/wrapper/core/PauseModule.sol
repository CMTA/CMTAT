//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../../openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../security/AuthorizationModule.sol";

/**
 *
 * @dev Put in pause or deactivate the contract
 * The issuer must be able to “pause” the smart contract, 
 * to prevent execution of transactions on the distributed ledger until the issuer puts an end to the pause. 
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract PauseModule is PausableUpgradeable, AuthorizationModule {
    string internal constant TEXT_TRANSFER_REJECTED_PAUSED =
        "All transfers paused";
    bool private isDeactivated;
    event Deactivated(address account);

    function __PauseModule_init(address admin, uint48 initialDelayToAcceptAdminRole) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        __Pausable_init_unchained();
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __AccessControlDefaultAdminRules_init_unchained(initialDelayToAcceptAdminRole, admin);
        /* CMTAT modules */
        // Security
        __AuthorizationModule_init_unchained();

        // own function
        __PauseModule_init_unchained();
    }

    function __PauseModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @notice Pauses all token transfers.
     * @dev See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     *
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpauses all token transfers.
     * @dev See {ERC20Pausable} and {Pausable-_unpause}.
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
    * @notice  deactivate the contract
    * Warning: the operation is irreversible, be careful
    * @dev
    * Emits a {Deactivated} event indicating that the contract has been deactivated.
    * Requirements:
    *
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function deactivateContract()
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        isDeactivated = true;
       _pause();
       emit Deactivated(_msgSender());
    }

    /**
    * @notice Returns true if the contract is deactivated, and false otherwise.
    */
    function deactivated() view public returns (bool){
        return isDeactivated;
    }

    uint256[50] private __gap;
}
