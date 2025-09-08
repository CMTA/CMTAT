//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseCommon} from "./0_CMTATBaseCommon.sol";
/* ==== Wrapper === */
// Core
import {PauseModule}  from "./wrapper/core/PauseModule.sol";
import {EnforcementModule} from "./wrapper/core/EnforcementModule.sol";
// Extensions
import {ERC20EnforcementModule, ERC20EnforcementModuleInternal} from "./wrapper/extensions/ERC20EnforcementModule.sol";
// Controllers
import {ValidationModuleRuleEngine} from "./wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol";

 /* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
import {Errors} from "../libraries/Errors.sol";
abstract contract CMTATBaseRuleEngine is
    CMTATBaseCommon,
    ValidationModuleRuleEngine
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
     * @param engines_ external contract
     */
    function initialize(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) public virtual initializer {
        __CMTAT_init(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_
        );
    }

    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory ExtraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) internal virtual onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();

        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();

        // Openzeppelin
        __CMTAT_openzeppelin_init_unchained();
        /* Internal Modules */
       __CMTAT_internal_init_unchained(engines_);

        /* Wrapper modules */
        __CMTAT_modules_init_unchained(admin, ERC20Attributes_, ExtraInformationAttributes_, engines_ );
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
    function __CMTAT_internal_init_unchained(ICMTATConstructor.Engine memory engines_) internal virtual onlyInitializing {
        __ValidationRuleEngine_init_unchained(engines_.ruleEngine);  
    }

    /*
    * @dev CMTAT wrapper modules
    */
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_, ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_, ICMTATConstructor.Engine memory engines_) internal virtual onlyInitializing {
        __CMTAT_commonModules_init_unchained(admin,ERC20Attributes_, extraInformationAttributes_, engines_.snapshotEngine, engines_ .documentEngine);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc ValidationModuleRuleEngine
    */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public virtual override (ValidationModuleRuleEngine) view returns (bool) {
        if(!ERC20EnforcementModuleInternal._checkActiveBalance(from, value)){
            return false;
        } else {
            return ValidationModuleRuleEngine.canTransfer(from, to, value);
        }
    }

    /**
    * @inheritdoc ValidationModuleRuleEngine
    */
   function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual override (ValidationModuleRuleEngine) view returns (bool) {
        if(!ERC20EnforcementModuleInternal._checkActiveBalance(from, value)){
            return false;
        } else {
            return ValidationModuleRuleEngine.canTransferFrom(spender, from, to, value);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _authorizePause() internal virtual override(PauseModule) onlyRole(PAUSER_ROLE){}
    function _authorizeDeactivate() internal virtual override(PauseModule) onlyRole(DEFAULT_ADMIN_ROLE){}

    function _authorizeFreeze() internal virtual override(EnforcementModule) onlyRole(ENFORCER_ROLE){}

    function _authorizeRuleEngineManagement() internal virtual override(ValidationModuleRuleEngine) onlyRole(DEFAULT_ADMIN_ROLE){}


    function _checkTransferred(address spender, address from, address to, uint256 value) internal virtual override(CMTATBaseCommon) {
        CMTATBaseCommon._checkTransferred(spender, from, to, value);
        require(ValidationModuleRuleEngine._transferred(spender, from, to, value), Errors.CMTAT_InvalidTransfer(from, to, value));
    } 
}
