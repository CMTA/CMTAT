//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
/* ==== controllers === */
import {ValidationModule} from "./wrapper/controllers/ValidationModule.sol";
/* ==== Wrapper === */
// Security
import {AccessControlModule, AccessControlUpgradeable} from "./wrapper/security/AccessControlModule.sol";
// Core
import {VersionModule} from "./wrapper/core/VersionModule.sol";
// Extensions
import {ExtraInformationModule} from "./wrapper/extensions/ExtraInformationModule.sol";
import {DocumentEngineModule, IERC1643} from "./wrapper/extensions/DocumentEngineModule.sol";
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
    VersionModule,
    // Extension
    DocumentEngineModule,
    ExtraInformationModule,
    AccessControlModule
{  
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        IERC1643 documentEngine_
    ) internal virtual onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();

        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();

        // Openzeppelin
        __CMTAT_openzeppelin_init_unchained();

        /* Wrapper modules */
        __CMTAT_modules_init_unchained(admin, extraInformationAttributes_, documentEngine_ );
    }

    /*
    * @dev OpenZeppelin
    */
    function __CMTAT_openzeppelin_init_unchained() internal virtual onlyInitializing {
         // AccessControlModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
    }

    /*
    * @dev CMTAT wrapper modules
    */
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_, IERC1643 documentEngine_ ) internal virtual onlyInitializing {
        // AccessControlModule_init_unchained is called firstly due to inheritance
        __AccessControlModule_init_unchained(admin);
        __DocumentEngineModule_init_unchained(documentEngine_);
        /* Other modules */
        __ExtraInformationModule_init_unchained(extraInformationAttributes_.tokenId, extraInformationAttributes_.terms, extraInformationAttributes_.information);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ==== Access Control ==== */
    function  _authorizeDocumentManagement() internal virtual override(DocumentEngineModule) onlyRole(DOCUMENT_ROLE){}
    function  _authorizeExtraInfoManagement() internal virtual override(ExtraInformationModule) onlyRole(EXTRA_INFORMATION_ROLE){}
}
