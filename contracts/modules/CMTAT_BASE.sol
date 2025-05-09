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
import {ERC20EnforcementModule} from "./wrapper/extensions/ERC20EnforcementModule.sol";
import {ExtraInformationModule} from "./wrapper/extensions/ExtraInformationModule.sol";
import {PauseModule} from "./wrapper/core/PauseModule.sol";
import {ValidationModule,ValidationModuleCore, IERC1404} from "./wrapper/controllers/ValidationModule.sol";
import {MetaTxModule, ERC2771ContextUpgradeable} from "./wrapper/extensions/MetaTxModule.sol";
import {DebtEngineModule} from "./wrapper/extensions/DebtEngineModule.sol";
import {DocumentEngineModule} from "./wrapper/extensions/DocumentEngineModule.sol";
import {SnapshotEngineModule} from "./wrapper/extensions/SnapshotEngineModule.sol";
// Security
import {AuthorizationModule} from "./security/AuthorizationModule.sol";
 /* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
import {ISnapshotEngine} from "../interfaces/engine/ISnapshotEngine.sol";
import {Errors} from "../libraries/Errors.sol";
//import {CMTATBaseCore} from "./CMTATBaseCore.sol";
abstract contract CMTAT_BASE is
    // OpenZeppelin
    Initializable,
    ContextUpgradeable,
    // Core
    BaseModule,
    //PauseModule,
    ERC20MintModule,
    ERC20BurnModule,
    //EnforcementModule,
    ValidationModule,
    ERC20BaseModule,
    // Extension
    MetaTxModule,
    DebtEngineModule,
    SnapshotEngineModule,
    ERC20EnforcementModule,
    DocumentEngineModule,
    ExtraInformationModule
{  
 
    function _checkTransfer(address spender, address from, address to, uint256 value) internal {
        if(!_checkActiveBalance(from, value)){
            revert Errors.CMTAT_InvalidTransfer(from, to, value);
        }
        if (!ValidationModule._operateOnTransfer(spender, from, to, value)) {
            revert Errors.CMTAT_InvalidTransfer(from, to, value);
        }
    } 

    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice
     * initialize the proxy contract
     * The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param baseModuleAttributes_ tokenId, terms, information
     * @param engines_ external contract
     */
    function initialize(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) public virtual initializer {
        __CMTAT_init(
            admin,
            ERC20Attributes_,
            baseModuleAttributes_,
            engines_
        );
    }


    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_,
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
       __CMTAT_internal_init_unchained();

        /* Wrapper modules */
        __CMTAT_modules_init_unchained(admin, ERC20Attributes_, baseModuleAttributes_, engines_ );

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
    function __CMTAT_modules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_, ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_, ICMTATConstructor.Engine memory engines_ ) internal virtual onlyInitializing {
        // AuthorizationModule_init_unchained is called firstly due to inheritance
        __AuthorizationModule_init_unchained(admin);
        __ERC20BurnModule_init_unchained();
        __ERC20MintModule_init_unchained();
        // EnforcementModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __EnforcementModule_init_unchained();
        __ERC20BaseModule_init_unchained(ERC20Attributes_.decimalsIrrevocable, ERC20Attributes_.name, ERC20Attributes_.symbol);
        // PauseModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __PauseModule_init_unchained();
        __ValidationModule_init_unchained(engines_.ruleEngine);

        __SnapshotEngineModule_init_unchained(engines_.snapshotEngine);
        __DocumentEngineModule_init_unchained(engines_ .documentEngine);
        __DebtEngineModule_init_unchained(engines_ .debtEngine);
        __ERC20EnforcementModule_init_unchained();
        /* Other modules */
        __ExtraInformationModule_init_unchained(baseModuleAttributes_.tokenId, baseModuleAttributes_.terms, baseModuleAttributes_.information);
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
    function transfer(address to, uint256 value) public virtual override returns (bool) {
         address from = _msgSender();
        _checkTransfer(address(0), from, to, value);
        _transfer(from, to, value);
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
        _checkTransfer(_msgSender(), from, to, value);
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

    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public virtual view override(ValidationModule ) returns (uint8 code) {
        uint256 frozenTokensLocal = getFrozenTokens(from);
        if(frozenTokensLocal > 0 ){
            uint256 activeBalance = balanceOf(from) - frozenTokensLocal;
            if(value > activeBalance) {
                return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE);
            }
        } 
        return ValidationModule.detectTransferRestriction(from, to, value);
    }

    function messageForTransferRestriction(
        uint8 restrictionCode
    )  public view virtual override(ValidationModule)  returns (string memory message) {
        if(restrictionCode == uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE)){
            return ERC20EnforcementModule.TEXT_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE;
        } else {
            return ValidationModule.messageForTransferRestriction(restrictionCode);
        }

    }

    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public virtual override (ValidationModule) view returns (bool) {
        if(!_checkActiveBalance(from, value)){
            return false;
        } else {
            return ValidationModule.canTransfer(from, to, value);
        }
        
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev we don't check the transfer validity here
     * 
     *
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20Upgradeable) {
        // We check here the address of the snapshotEngine here because we don't want to read balance/totalSupply if there is no Snapshot Engine
        ISnapshotEngine snapshotEngineLocal = snapshotEngine();
        // Required to be performed before the update
        if(address(snapshotEngineLocal) != address(0)){
            snapshotEngineLocal.operateOnTransfer(from, to, balanceOf(from), balanceOf(to), totalSupply());
        }
        ERC20Upgradeable._update(from, to, amount);
    }
    
        

    /**
    * @dev Check if the mint is valid
    */
    function _mintOverride(address account, uint256 value) internal virtual override(ERC20MintModule) {
        //require(ValidationModule.canMint(account, value), Errors.CMTAT_InvalidMint(account, value) );
        require(ValidationModuleCore._canMintBurnByModule(account), Errors.CMTAT_InvalidMint(account, value) );
        _checkTransfer(address(0), address(0), account, value);
        ERC20MintModule._mintOverride(account, value);
    }

    /**
    * @dev Check if the burn is valid
    */
    function _burnOverride(address account, uint256 value) internal virtual override(ERC20BurnModule) {
        //require(ValidationModule.canBurn(account, value), Errors.CMTAT_InvalidBurn(account, value) );
         require(ValidationModuleCore._canMintBurnByModule(account), Errors.CMTAT_InvalidBurn(account, value) );
        _checkTransfer(address(0), address(0), account, value);
        //ERC20EnforcementModule._unfreezeTokens(account, value);
        
        ERC20BurnModule._burnOverride(account, value);
    }



    /*//////////////////////////////////////////////////////////////
                            METATX MODULE
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgSender()
        internal virtual
        view
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _contextSuffixLength() internal virtual view 
    override(ERC2771ContextUpgradeable, ContextUpgradeable)
    returns (uint256) {
         return ERC2771ContextUpgradeable._contextSuffixLength();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgData()
        internal virtual
        view
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }
}
