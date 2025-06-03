//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Wrapper === */
// Core
import {BaseModule} from "./wrapper/core/BaseModule.sol";
import {ERC20BurnModule} from "./wrapper/core/ERC20BurnModule.sol";
import {ERC20MintModule} from "./wrapper/core/ERC20MintModule.sol";
// Extensions
import {ExtraInformationModule} from "./wrapper/extensions/ExtraInformationModule.sol";
import {ERC20EnforcementModule} from "./wrapper/extensions/ERC20EnforcementModule.sol";
// options
import {ERC20BaseModule, ERC20Upgradeable} from "./wrapper/core/ERC20BaseModule.sol";
// Other
import {DocumentEngineModule,  IERC1643} from "./wrapper/extensions/DocumentEngineModule.sol";
import {SnapshotEngineModule} from "./wrapper/extensions/SnapshotEngineModule.sol";

 /* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
import {ISnapshotEngine} from "../interfaces/engine/ISnapshotEngine.sol";
import {Errors} from "../libraries/Errors.sol";
abstract contract CMTATBaseCommon is
    // Core
    BaseModule,
    ERC20MintModule,
    ERC20BurnModule,
    ERC20BaseModule,
    // Extension
    SnapshotEngineModule,
    ERC20EnforcementModule,
    DocumentEngineModule,
    ExtraInformationModule
{  
 
    function _checkTransferred(address /*spender*/, address from, address to, uint256 value) internal virtual {
        if(!ERC20EnforcementModule._checkActiveBalance(from, value)){
            revert Errors.CMTAT_InvalidTransfer(from, to, value);
        }
    } 

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function __CMTAT_commonModules_init_unchained(address admin, ICMTATConstructor.ERC20Attributes memory ERC20Attributes_, ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_,
     ISnapshotEngine snapshotEngine,
        IERC1643 documentEngine ) internal virtual onlyInitializing {
        // AuthorizationModule_init_unchained is called firstly due to inheritance
        __AuthorizationModule_init_unchained(admin);

        // Core
        // EnforcementModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __ERC20BaseModule_init_unchained(ERC20Attributes_.decimalsIrrevocable, ERC20Attributes_.name, ERC20Attributes_.symbol);
        /* Extensions */
        // PauseModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __ExtraInformationModule_init_unchained(baseModuleAttributes_.tokenId, baseModuleAttributes_.terms, baseModuleAttributes_.information);
        __SnapshotEngineModule_init_unchained(snapshotEngine);
        __DocumentEngineModule_init_unchained(documentEngine);
    }

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


    /**
    * @inheritdoc ERC20BaseModule
    */
    function name() public virtual override(ERC20Upgradeable, ERC20BaseModule) view returns (string memory) {
        return ERC20BaseModule.name();
    }

    /**
    * @inheritdoc ERC20BaseModule
    */
    function symbol() public virtual override(ERC20Upgradeable, ERC20BaseModule) view returns (string memory) {
        return ERC20BaseModule.symbol();
    }


    /* ============  State Functions ============ */
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable) returns (bool) {
         address from = _msgSender();
        _checkTransferred(address(0), from, to, value);
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
        _checkTransferred(_msgSender(), from, to, value);
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
        _checkTransferred(address(0), address(0), account, value);
        ERC20MintModule._mintOverride(account, value);
    }

    /**
    * @dev Check if the burn is valid
    */
    function _burnOverride(address account, uint256 value) internal virtual override(ERC20BurnModule) {
        _checkTransferred(address(0),  account, address(0), value);
        ERC20BurnModule._burnOverride(account, value);
    }
}
