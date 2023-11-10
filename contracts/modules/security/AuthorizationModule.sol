//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../openzeppelin-contracts-upgradeable/contracts/access/extensions/AccessControlDefaultAdminRulesUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

import "../../libraries/Errors.sol";

abstract contract AuthorizationModule is AccessControlDefaultAdminRulesUpgradeable {
    // BurnModule
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    // CreditEvents
    bytes32 public constant DEBT_CREDIT_EVENT_ROLE =
    keccak256("DEBT_CREDIT_EVENT_ROLE");
    // DebtModule
    bytes32 public constant DEBT_ROLE = keccak256("DEBT_ROLE");
    // EnforcementModule
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
    // MintModule
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // PauseModule
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // SnapshotModule
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");

   

    function __AuthorizationModule_init(
        address admin,
        uint48 initialDelay
    ) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __AccessControlDefaultAdminRules_init_unchained(initialDelay, admin);

        /* own function */
        __AuthorizationModule_init_unchained();
    }

    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __AuthorizationModule_init_unchained(
    ) internal view onlyInitializing {
    }

    /*
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override( IAccessControl,  AccessControlUpgradeable) returns (bool) {
        // The Default Admin has all roles
        if (AccessControlUpgradeable.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        }
        return AccessControlUpgradeable.hasRole(role, account);
    }

    /**
    @notice
    Warning: this function should be called only in case of necessity (e.g private key leak)
    Its goal is to transfer the adminship of the contract to a new admin, whithout delay.
    The prefer way is to use the workflow of AccessControlDefaultAdminRulesUpgradeable
    */
    function transferAdminshipDirectly(address newAdmin) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        // we revoke first the admin since we can only have one admin
        _revokeRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
    }
    uint256[50] private __gap;
}
