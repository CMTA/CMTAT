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
import {PauseModule} from "./wrapper/core/PauseModule.sol";
import {ValidationModuleCore} from "./wrapper/controllers/ValidationModuleCore.sol";

// Security
import {AuthorizationModule} from "./security/AuthorizationModule.sol";

/* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
import {ISnapshotEngine} from "../interfaces/engine/ISnapshotEngine.sol";
import {Errors} from "../libraries/Errors.sol";

abstract contract CMTATBaseCore is
    // OpenZeppelin
    Initializable,
    ContextUpgradeable,
    BaseModule,
    // Core
    ERC20MintModule,
    ERC20BurnModule,
    ValidationModuleCore,
    ERC20BaseModule
{  
    error CMTAT_BurnEnforcement_AddressIsNotFrozen(); 
    event Enforcement (address indexed enforcer, address indexed account, uint256 amount, bytes data);
 
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
        __Enforcement_init_unchained();   
    }

    /*
    * @dev CMTAT wrapper modules
    */
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_ ) internal virtual onlyInitializing {
        // AuthorizationModule_init_unchained is called firstly due to inheritance
        __AuthorizationModule_init_unchained(admin);
        __ERC20BurnModule_init_unchained();
        __ERC20MintModule_init_unchained();
        // EnforcementModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __EnforcementModule_init_unchained();
        __ERC20BaseModule_init_unchained(ERC20Attributes_.decimalsIrrevocable, ERC20Attributes_.name, ERC20Attributes_.symbol);
        // PauseModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __PauseModule_init_unchained();
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
     * @notice Returns the number of decimals used to get its user representation.
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


    /**
     * @notice Returns the name of the token.
     */
    function name() public virtual override(ERC20Upgradeable, ERC20BaseModule) view returns (string memory) {
        return ERC20BaseModule.name();
    }

    /**
     * @notice Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public virtual override(ERC20Upgradeable, ERC20BaseModule) view returns (string memory) {
        return ERC20BaseModule.symbol();
    }

    /* ============  State Functions ============ */
        /* ============  State Functions ============ */
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
        require(ValidationModuleCore.canTransfer(from, to, value), Errors.CMTAT_InvalidTransfer(from, to, value) );
        return ERC20BaseModule.transferFrom(from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                Functions requiring several modules
    //////////////////////////////////////////////////////////////*/

    /**
    * @notice burn and mint atomically
    * @param from current token holder to burn tokens
    * @param to receiver to send the new minted tokens
    * @param amountToBurn number of tokens to burn
    * @param amountToMint number of tokens to mint
    * @dev 
    * - The access control is managed by the functions burn (ERC20BurnModule) and mint (ERC20MintModule)
    * - Input validation is also managed by the functions burn and mint
    * - You can mint more tokens than burnt
    */
    function burnAndMint(address from, address to, uint256 amountToBurn, uint256 amountToMint, bytes calldata data) public virtual  {
        burn(from, amountToBurn, data);
        mint(to, amountToMint, data);
    }

    /**
    * @notice allows the issuer to burn tokens from a frozen address
    */
    function forceBurn(
        address account,
        uint256 value,
        bytes memory data
    ) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        require(EnforcementModule.isFrozen(account), CMTAT_BurnEnforcement_AddressIsNotFrozen());
        _burn(account, value);
        emit Enforcement(_msgSender(), account, value, data);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @dev 
    */
    function _mint(address account, uint256 value, bytes memory data) internal virtual override(ERC20MintModule) {
        require(ValidationModuleCore._canMintBurnByModule(account), Errors.CMTAT_InvalidTransfer(address(0), account, value) );
        ERC20MintModule._mint(account, value, data);
    }


    function _burn(address account, uint256 value, bytes memory data) internal virtual override(ERC20BurnModule) {
        require(ValidationModuleCore._canMintBurnByModule(account), Errors.CMTAT_InvalidTransfer(account, address(0), value) );
        ERC20BurnModule._burn(account, value, data);
    }
}
