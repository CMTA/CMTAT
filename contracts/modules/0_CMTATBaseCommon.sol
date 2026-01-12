// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


/* ==== Wrapper === */
// Core
import {VersionModule} from "./wrapper/core/VersionModule.sol";
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
import {ISnapshotEngine} from "../interfaces/engine/ISnapshotEngine.sol";
import {IBurnMintERC20} from "../interfaces/technical/IMintBurnToken.sol";
import {IERC5679} from "../interfaces/technical/IERC5679.sol";

abstract contract CMTATBaseCommon is
    // Core
    VersionModule,
    ERC20MintModule,
    ERC20BurnModule,
    ERC20BaseModule,
    // Extension
    SnapshotEngineModule,
    ERC20EnforcementModule,
    DocumentEngineModule,
    ExtraInformationModule,
    // Interfaces
    IBurnMintERC20,
    IERC5679
{  


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
    function name() public view virtual override(ERC20Upgradeable, ERC20BaseModule)  returns (string memory) {
        return ERC20BaseModule.name();
    }

    /**
    * @inheritdoc ERC20BaseModule
    */
    function symbol() public view virtual override(ERC20Upgradeable, ERC20BaseModule) returns (string memory) {
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
    * @inheritdoc IBurnMintERC20
    * @dev 
    * - The access control is managed by the functions burn (ERC20BurnModule) and mint (ERC20MintModule)
    * - Input validation is also managed by the functions burn and mint
    * - You can mint more tokens than burnt
    */
    function burnAndMint(address from, address to, uint256 amountToBurn, uint256 amountToMint, bytes calldata data) 
    public virtual override(IBurnMintERC20) {
        ERC20BurnModule.burn(from, amountToBurn, data);
        ERC20MintModule.mint(to, amountToMint, data);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _checkTransferred(address /*spender*/, address from, address /* to */, uint256 value) internal virtual {
        ERC20EnforcementModuleInternal._checkActiveBalanceAndRevert(from, value);
    } 
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
      
        if(address(snapshotEngineLocal) != address(0)){
          uint256 fromBalanceBefore = balanceOf(from);
          uint256 toBalanceBefore = balanceOf(to);
          uint256 totalSupplyBefore = totalSupply();
        
          // We perform the update here (CEI pattern)
          ERC20Upgradeable._update(from, to, amount);

          // Required to use the balance before the update
          snapshotEngineLocal.operateOnTransfer(from, to, fromBalanceBefore, toBalanceBefore, totalSupplyBefore);
        } else {
            // Update without snapshot call
            ERC20Upgradeable._update(from, to, amount);
        }
    }

    /* ==== Mint and Burn Operations ==== */
    
    /**
    * @dev 
    * Mint path
    * Check if the mint is valid
    */
    function _mintOverride(address account, uint256 value) internal virtual override(ERC20MintModuleInternal) {
        _checkTransferred(address(0), address(0), account, value);
        ERC20MintModuleInternal._mintOverride(account, value);
    }

    /**
    * @dev 
    * Burn path
    * Check if the burn is valid
    */
    function _burnOverride(address account, uint256 value) internal virtual override(ERC20BurnModuleInternal) {
        _checkTransferred(address(0),  account, address(0), value);
        ERC20BurnModuleInternal._burnOverride(account, value);
    }

    /**
    * @dev 
    * Minter-initiated transfer path
    * Check if a minter transfer is valid
    */
    function _minterTransferOverride(address from, address to, uint256 value) internal virtual override(ERC20MintModuleInternal) {
        _checkTransferred(address(0), from, to, value);
        ERC20MintModuleInternal._minterTransferOverride(from, to, value);
    }
}
