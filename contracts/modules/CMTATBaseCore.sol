//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
/* ==== Wrapper === */
// ERC20
import {ERC20BurnModule} from "./wrapper/core/ERC20BurnModule.sol";
import {ERC20MintModule} from "./wrapper/core/ERC20MintModule.sol";
import {ERC20BaseModule, ERC20Upgradeable} from "./wrapper/core/ERC20BaseModule.sol";

// Other
import {BaseModule} from "./wrapper/core/BaseModule.sol";
import {EnforcementModule} from "./wrapper/core/EnforcementModule.sol";
import {ValidationModule, ValidationModuleCore} from "./wrapper/core/ValidationModuleCore.sol";

// Security
import {AuthorizationModule} from "./security/AuthorizationModule.sol";

/* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
import {IForcedBurnERC20} from "../interfaces/technical/IMintBurnToken.sol";
import {IBurnMintERC20} from "../interfaces/technical/IMintBurnToken.sol";
import {IERC7551ERC20EnforcementEvent} from "../interfaces/tokenization/draft-IERC7551.sol";
import {Errors} from "../libraries/Errors.sol";

/**
* @dev CMTAT with core modules
*/
abstract contract CMTATBaseCore is
    // OpenZeppelin
    Initializable,
    ContextUpgradeable,
    BaseModule,
    // Core
    ERC20MintModule,
    ERC20BurnModule,
    ValidationModuleCore,
    ERC20BaseModule,
    IForcedBurnERC20,
    IBurnMintERC20,
    IERC7551ERC20EnforcementEvent
{  
    error CMTAT_BurnEnforcement_AddressIsNotFrozen(); 
    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice
     * initialize the proxy contract
     * The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     */
    function initialize(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_
    ) public virtual initializer {
        __CMTAT_init(
            admin,
            ERC20Attributes_
        );
    }


    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_
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
        __CMTAT_modules_init_unchained(admin, ERC20Attributes_);

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
        // We don'use name and symbol set by the OpenZeppelin module
        //__ERC20_init_unchained(ERC20Attributes_.name, ERC20Attributes_.symbol);
    }



    /*
    * @dev CMTAT internal module
    */
    function __CMTAT_internal_init_unchained() internal virtual onlyInitializing {
        // nothing to do
    }

    /*
    * @dev CMTAT wrapper modules
    */
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_ ) internal virtual onlyInitializing {
        // AuthorizationModule_init_unchained is called firstly due to inheritance
        __AuthorizationModule_init_unchained(admin);
        __ERC20BaseModule_init_unchained(ERC20Attributes_.decimalsIrrevocable, ERC20Attributes_.name, ERC20Attributes_.symbol);
    }

    function __CMTAT_init_unchained() internal virtual onlyInitializing {
        // no variable to initialize
        
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                Override ERC20Upgradeable, ERC20BaseModule
    //////////////////////////////////////////////////////////////*/

    /* ============  View Functions ============ */

    /**
    * @inheritdoc ERC20BaseModule
    */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, ERC20BaseModule)
        returns (uint8)
    {
        return ERC20BaseModule.decimals();
    }


    /*
    * @inheritdoc ERC20BaseModule
    */
    function name() public virtual override(ERC20Upgradeable, ERC20BaseModule) view returns (string memory) {
        return ERC20BaseModule.name();
    }

    /*
    * @inheritdoc ERC20BaseModule
    */
    function symbol() public virtual override(ERC20Upgradeable, ERC20BaseModule) view returns (string memory) {
        return ERC20BaseModule.symbol();
    }

    /* ============  State Functions ============ */
    /*
    * @inheritdoc ERC20Upgradeable
    */
    function transfer(address to, uint256 value) public virtual override returns (bool) {
        address from = _msgSender();
        require(ValidationModuleCore.canTransfer(from, to, value), Errors.CMTAT_InvalidTransfer(from, to, value) );
        ERC20Upgradeable._transfer(from, to, value);
        return true;
    }
    /*
    * @inheritdoc ERC20BaseModule
    */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        virtual
        override(ERC20Upgradeable, ERC20BaseModule)
        returns (bool)
    {
        require(ValidationModuleCore.canTransferFrom(_msgSender(),from, to, value), Errors.CMTAT_InvalidTransfer(from, to, value) );
        return ERC20BaseModule.transferFrom(from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                Functions requiring several modules
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc IBurnMintERC20
    * @dev 
    * - The access control is managed by the functions burn (ERC20BurnModule) and mint (ERC20MintModule)
    * - Input validation is also managed by the functions burn and mint
    * - You can mint more tokens than burnt
    */
    function burnAndMint(address from, address to, uint256 amountToBurn, uint256 amountToMint, bytes calldata data) public virtual override(IBurnMintERC20) {
        ERC20BurnModule.burn(from, amountToBurn, data);
        ERC20MintModule.mint(to, amountToMint, data);
    }

    /**
    * @inheritdoc IForcedBurnERC20
    */
    function forcedBurn(
        address account,
        uint256 value,
        bytes memory data
    ) public virtual override(IForcedBurnERC20) onlyRole(DEFAULT_ADMIN_ROLE) {
        require(EnforcementModule.isFrozen(account), CMTAT_BurnEnforcement_AddressIsNotFrozen());
        // Skip ERC20BurnModule
        ERC20Upgradeable._burn(account, value);
        emit Enforcement(_msgSender(), account, value, data);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc ERC20MintModule
    */
    function _mint(address account, uint256 value, bytes memory data) internal virtual override(ERC20MintModule) {
        require(ValidationModule._canMintBurnByModule(account), Errors.CMTAT_InvalidTransfer(address(0), account, value) );
        ERC20MintModule._mint(account, value, data);
    }

    /**
    * @inheritdoc ERC20BurnModule
    */
    function _burn(address account, uint256 value, bytes memory data) internal virtual override(ERC20BurnModule) {
        require(ValidationModule._canMintBurnByModule(account), Errors.CMTAT_InvalidTransfer(account, address(0), value) );
        ERC20BurnModule._burn(account, value, data);
    }
}
