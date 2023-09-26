//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// required OZ imports here
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";

import "../../modules/security/AuthorizationModule.sol";


abstract contract AuthorizationModuleInitTest is
    Initializable,
    ContextUpgradeable,
    AuthorizationModule
{
    /**
     * @notice
     * initialize the proxy contract
     * The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param initialDelayToAcceptAdminRole delay to revoke the admin transfer
     */
    function initialize(
        address admin,
        uint48 initialDelayToAcceptAdminRole
    ) public initializer {
        __AuthorizationModuleInitTest_init(
            admin,
            initialDelayToAcceptAdminRole
        );
    }

    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __AuthorizationModuleInitTest_init(
        address admin,
        uint48 initialDelayToAcceptAdminRole
    ) internal onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __AccessControlDefaultAdminRules_init_unchained(initialDelayToAcceptAdminRole, admin);

        /* Wrapper */
        // AuthorizationModule_init_unchained is called firstly due to inheritance
        __AuthorizationModule_init_unchained();
        /* own function */
        __AuthorizationModuleInitTest_init_unchained();
    }

    function __AuthorizationModuleInitTest_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    uint256[50] private __gap;
}
