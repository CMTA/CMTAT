// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";
/* ==== Wrapper === */
// Security
import {AccessControlUpgradeable, AccessControlModule} from "./wrapper/security/AccessControlModule.sol";
// Core
import {ERC20BurnModule, ERC20BurnModuleInternal} from "./wrapper/core/ERC20BurnModule.sol";
import {ERC20MintModule, ERC20MintModuleInternal} from "./wrapper/core/ERC20MintModule.sol";
// Extensions
import {ExtraInformationModule} from "./wrapper/extensions/ExtraInformationModule.sol";
import {ERC20EnforcementModule, ERC20EnforcementModuleInternal} from "./wrapper/extensions/ERC20EnforcementModule.sol";
import {DocumentEngineModule,  IERC1643} from "./wrapper/extensions/DocumentEngineModule.sol";
import {SnapshotEngineModule} from "./wrapper/extensions/SnapshotEngineModule.sol";
// options
import {ERC20BaseModule, ERC20Upgradeable} from "./wrapper/core/ERC20BaseModule.sol";
 /* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
import {CMTATBaseCommon} from "./0_CMTATBaseCommon.sol";
abstract contract CMTATBaseAccessControl is
    AccessControlModule,
    CMTATBaseCommon
{  
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    function __CMTAT_commonModules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_, ICMTATConstructor.ExtraInformationAttributes memory ExtraInformationModuleAttributes_) internal virtual onlyInitializing {
        // AccessControlModule_init_unchained is called firstly due to inheritance
        __AccessControlModule_init_unchained(admin);
        // Core
        __ERC20BaseModule_init_unchained(ERC20Attributes_.decimalsIrrevocable, ERC20Attributes_.name, ERC20Attributes_.symbol);
        /* Extensions */
        __ExtraInformationModule_init_unchained(ExtraInformationModuleAttributes_.tokenId, ExtraInformationModuleAttributes_.terms, ExtraInformationModuleAttributes_.information);
    }
    
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @inheritdoc AccessControlUpgradeable
     * @dev 
     * We can not use type(IERC5679).interfaceId instead of 0xd0017968
     * because IERC5679 inherits from two interfaces (IERC5679Burn and Mint)
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, IERC165) returns (bool) {
        return interfaceId == 0xd0017968 || AccessControlUpgradeable.supportsInterface(interfaceId);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control Functions ==== */

    /** 
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function _authorizeERC20AttributeManagement() internal virtual override(ERC20BaseModule) onlyRole(DEFAULT_ADMIN_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `MINTER_ROLE`.
    */
    function _authorizeMint() internal virtual override(ERC20MintModule) onlyRole(MINTER_ROLE){}

    /** 
    * @custom:access-control
    * - The caller must have the `BURNER_ROLE`.
    */
    function _authorizeBurn() internal virtual override(ERC20BurnModule) onlyRole(BURNER_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `DOCUMENT_ROLE`.
    */
    function  _authorizeDocumentManagement() internal virtual override(DocumentEngineModule) onlyRole(DOCUMENT_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    function  _authorizeExtraInfoManagement() internal virtual override(ExtraInformationModule) onlyRole(EXTRA_INFORMATION_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `ERC20ENFORCER_ROLE`.
    */
    function _authorizeERC20Enforcer() internal virtual override(ERC20EnforcementModule) onlyRole(ERC20ENFORCER_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function _authorizeForcedTransfer() internal virtual override(ERC20EnforcementModule) onlyRole(DEFAULT_ADMIN_ROLE){}

    /** 
    * @custom:access-control
    * - the caller must have the `SNAPSHOOTER_ROLE`.
    */
    function _authorizeSnapshots() internal virtual override(SnapshotEngineModule) onlyRole(SNAPSHOOTER_ROLE){}
}
