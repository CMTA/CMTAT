//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

abstract contract AuthorizationModule is AccessControlUpgradeable {
    // BurnModule
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    // EnforcementModule
    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
    // MintModule
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    // PauseModule
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    // SnapshotModule
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");
    // DebtModule
    bytes32 public constant DEBT_ROLE = keccak256("DEBT_ROLE");
    // CreditEvents
    bytes32 public constant DEBT_CREDIT_EVENT_ROLE = keccak256("DEBT_CREDIT_EVENT_ROLE");
    
    function __AuthorizationModule_init(address admin) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        __AccessControl_init_unchained();

       /* own function */
        __AuthorizationModule_init_unchained(admin);
    }

    function __AuthorizationModule_init_unchained(address admin) internal onlyInitializing {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        // EnforcementModule
        _grantRole(ENFORCER_ROLE, admin);
        // MintModule
        _grantRole(MINTER_ROLE, admin);
        // BurnModule
        _grantRole(BURNER_ROLE, admin);
        // PauseModule
        _grantRole(PAUSER_ROLE, admin);
        // SnapshotModule
        _grantRole(SNAPSHOOTER_ROLE, admin);
        // DebtModule
        _grantRole(DEBT_ROLE, admin);
        // CreditEvents 
        _grantRole(DEBT_CREDIT_EVENT_ROLE, admin);
    }

    /*
    @notice Transfers adminship from one address to another
    The newAdmin will have the same roles as the current admin.
    Warning: make sure the address of newAdmin is correct.
    By transfering his rights, the former admin loses them all.
    @param newAdmin address of the new admin
    */
    function transferAdminship(address newAdmin) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newAdmin != address(0), "Address 0 not allowed");
        address sender = _msgSender();
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        // EnforcementModule
        if(hasRole(ENFORCER_ROLE, sender)){
            grantRole(ENFORCER_ROLE, newAdmin);
            renounceRole(ENFORCER_ROLE, sender);
        }
        // MintModule
        if(hasRole(MINTER_ROLE, sender)){
            grantRole(MINTER_ROLE, newAdmin);
            renounceRole(MINTER_ROLE, sender);
        }
        // BurnModule
        if(hasRole(BURNER_ROLE, sender)){
            grantRole(BURNER_ROLE, newAdmin);
            renounceRole(BURNER_ROLE, sender);
        }
        // PauseModule
        if(hasRole(PAUSER_ROLE, sender)){
            grantRole(PAUSER_ROLE, newAdmin);
            renounceRole(PAUSER_ROLE, sender);
        }
        // SnapshotModule
        if(hasRole(SNAPSHOOTER_ROLE, sender)){
            grantRole(SNAPSHOOTER_ROLE, newAdmin);
            renounceRole(SNAPSHOOTER_ROLE, sender);
        }

        // DebtModule
        if(hasRole(DEBT_ROLE, sender)){
            grantRole(DEBT_ROLE, newAdmin);
            renounceRole(DEBT_ROLE, sender);
        }

        // CreditEvents
        if(hasRole(DEBT_CREDIT_EVENT_ROLE, sender)){
            grantRole(DEBT_CREDIT_EVENT_ROLE, newAdmin);
            renounceRole(DEBT_CREDIT_EVENT_ROLE, sender);
        }
        renounceRole(DEFAULT_ADMIN_ROLE, sender);
    }

    uint256[50] private __gap;
}
