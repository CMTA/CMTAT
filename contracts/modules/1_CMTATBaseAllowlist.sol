//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
/* ==== Wrapper === */
// Base
import {CMTATBaseCommon, AccessControlUpgradeable} from "./0_CMTATBaseCommon.sol";
// Extensions
import {ERC20EnforcementModule, ERC20EnforcementModuleInternal} from "./wrapper/extensions/ERC20EnforcementModule.sol";
import {DocumentEngineModule, IERC1643} from "./wrapper/extensions/DocumentEngineModule.sol";
// options
import {ERC2771Module, ERC2771ContextUpgradeable} from "./wrapper/options/ERC2771Module.sol";
// controller
import {ValidationModuleAllowlist} from "./wrapper/controllers/ValidationModuleAllowlist.sol";
import {ValidationModule, ValidationModuleCore} from "./wrapper/core/ValidationModuleCore.sol";
 /* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
import {ISnapshotEngine} from "../interfaces/engine/ISnapshotEngine.sol";
import {Errors} from "../libraries/Errors.sol";
abstract contract CMTATBaseAllowlist is
    // OpenZeppelin
    Initializable,
    ContextUpgradeable,
    // Core
    CMTATBaseCommon,
    ValidationModuleAllowlist,
    ValidationModuleCore,
    ERC2771Module
{  
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice
     * initialize the proxy contract
     * The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param extraInformationAttributes_ tokenId, terms, information
     * @param snapshotEngine_ external contract
     * @param documentEngine_ external contract
     */
    function initialize(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ISnapshotEngine snapshotEngine_,
        IERC1643 documentEngine_
    ) public virtual initializer {
        __CMTAT_init(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            snapshotEngine_,
            documentEngine_
        );
    }


    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ISnapshotEngine snapshotEngine_,
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
        __CMTAT_modules_init_unchained(admin, ERC20Attributes_, extraInformationAttributes_, snapshotEngine_, documentEngine_ );
    }

    /*
    * @dev OpenZeppelin
    */
    function __CMTAT_openzeppelin_init_unchained() internal virtual onlyInitializing {
         // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __Pausable_init_unchained();
        // We don'use name and symbol set by the OpenZeppelin module
        //__ERC20_init_unchained(ERC20Attributes_.name, ERC20Attributes_.symbol);
    }



    /*
    * @dev CMTAT internal module
    */

    /*
    * @dev CMTAT wrapper modules
    */
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_, ICMTATConstructor.ExtraInformationAttributes memory ExtraInformationAttributes_,  ISnapshotEngine snapshotEngine_,
        IERC1643 documentEngine_ ) internal virtual onlyInitializing {
         __CMTAT_commonModules_init_unchained(admin,ERC20Attributes_, ExtraInformationAttributes_, snapshotEngine_, documentEngine_);
        // option
        __Allowlist_init_unchained();
    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    
    /*//////////////////////////////////////////////////////////////
                Functions requiring several modules
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc ValidationModuleCore
    */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public virtual override (ValidationModuleCore) view returns (bool) {
        if(!_canTransferGenericByModule(address(0), from, to)){
            return false;
        } else if(!ERC20EnforcementModuleInternal._checkActiveBalance(from, value)){
            return false;
        } else {
            return ValidationModuleCore.canTransfer(from, to, value);
        }
        
    }

    /**
    * @inheritdoc ValidationModuleCore
    */
   function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual override (ValidationModuleCore) view returns (bool) {
        if(!_canTransferGenericByModule(spender, from, to)){
            return false;
        }else if(!ERC20EnforcementModuleInternal._checkActiveBalance(from, value)){
            return false;
        }else {
            return ValidationModuleCore.canTransferFrom(spender, from, to, value);
        }  
    }

    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable, CMTATBaseCommon) returns (bool) {
        return CMTATBaseCommon.hasRole(role, account);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc ValidationModuleAllowlist
    */
    function _canMintBurnByModule(
        address target
    ) internal view virtual override(ValidationModuleAllowlist, ValidationModule) returns (bool) {
        return ValidationModuleAllowlist._canMintBurnByModule(target);
    }

    /**
    * @inheritdoc ValidationModuleAllowlist
    */
   function _canTransferGenericByModule(
        address spender,
        address from,
        address to
    ) internal view virtual override(ValidationModuleAllowlist, ValidationModule) returns (bool) {
        return ValidationModuleAllowlist._canTransferGenericByModule(spender, from, to);
    }

    function _checkTransferred(address spender, address from, address to, uint256 value) internal virtual override {
        CMTATBaseCommon._checkTransferred(spender, from, to, value);
        if (!ValidationModuleAllowlist._canTransferGenericByModule(spender, from, to)) {
            revert Errors.CMTAT_InvalidTransfer(from, to, value);
        }
    } 


    /*//////////////////////////////////////////////////////////////
                            METAXTX MODULE
    //////////////////////////////////////////////////////////////*/
       /**
     * @dev This surcharge is not necessary if you do not use the ERC2771Module
     */
    function _msgSender()
        internal virtual
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the ERC2771Module
     */
    function _contextSuffixLength() internal virtual view 
    override(ContextUpgradeable, ERC2771ContextUpgradeable)
    returns (uint256) {
         return ERC2771ContextUpgradeable._contextSuffixLength();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the ERC2771Module
     */
    function _msgData()
        internal virtual
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }
}
