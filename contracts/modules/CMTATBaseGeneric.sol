//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
/* ==== controllers === */
import {ValidationModule} from "./wrapper/controllers/ValidationModule.sol";
/* ==== Wrapper === */
// Core
import {BaseModule} from "./wrapper/core/BaseModule.sol";
// Extensions
import {ExtraInformationModule} from "./wrapper/extensions/ExtraInformationModule.sol";
import {DocumentEngineModule, IERC1643} from "./wrapper/extensions/DocumentEngineModule.sol";
// Security
import {AuthorizationModule} from "./security/AuthorizationModule.sol";
 /* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";

/**
* @dev CMTAT with no-related ERC-20 modules
*/
abstract contract CMTATBaseGeneric is
    // OpenZeppelin
    Initializable,
    ContextUpgradeable,
    // Enforcement & PauseModule
    ValidationModule,
    // Core
    BaseModule,
    // Extension
    DocumentEngineModule,
    ExtraInformationModule
{  
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_,
        IERC1643 documentEngine
    ) internal virtual onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();

        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();

        // Openzeppelin
        __CMTAT_openzeppelin_init_unchained();
        /* Internal Modules */
       __CMTAT_internal_init_unchained();

        /* Wrapper modules */
        __CMTAT_modules_init_unchained(admin, baseModuleAttributes_, documentEngine );

        /* own function */
        __CMTAT_init_unchained();
    }

    /*
    * @dev OpenZeppelin
    */
    function __CMTAT_openzeppelin_init_unchained() internal virtual onlyInitializing {
         // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
    }

    /*
    * @dev CMTAT internal module
    */
    function __CMTAT_internal_init_unchained() internal virtual onlyInitializing {
        __Enforcement_init_unchained();   
    }

    /*
    * @dev CMTAT wrapper modules
    */
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_, IERC1643 documentEngine ) internal virtual onlyInitializing {
        // AuthorizationModule_init_unchained is called firstly due to inheritance
        __AuthorizationModule_init_unchained(admin);
        // EnforcementModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __EnforcementModule_init_unchained();
        // PauseModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __PauseModule_init_unchained();
        __DocumentEngineModule_init_unchained(documentEngine);
        /* Other modules */
        __ExtraInformationModule_init_unchained(baseModuleAttributes_.tokenId, baseModuleAttributes_.terms, baseModuleAttributes_.information);
    }

    function __CMTAT_init_unchained() internal virtual onlyInitializing {
        // no variable to initialize
    }
}
