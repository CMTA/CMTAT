// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;


/* ==== Wrapper === */
// Core
import {VersionModule} from "./wrapper/core/VersionModule.sol";
import {ERC20BurnModule, ERC20BurnModuleInternal} from "./wrapper/core/ERC20BurnModule.sol";
import {ERC20MintModule, ERC20MintModuleInternal} from "./wrapper/core/ERC20MintModule.sol";
// Extensions
import {ExtraInformationModule} from "./wrapper/extensions/ExtraInformationModule.sol";
import {ERC20EnforcementModule, ERC20EnforcementModuleInternal} from "./wrapper/extensions/ERC20EnforcementModule.sol";
// options
import {ERC20BaseModule, ERC20Upgradeable} from "./wrapper/core/ERC20BaseModule.sol";
import {TokenAttributeModule} from "./wrapper/core/TokenAttributeModule.sol";
 /* ==== Interface and other library === */
import {IBurnMintERC20} from "../interfaces/technical/IMintBurnToken.sol";
import {IERC5679} from "../interfaces/technical/IERC5679.sol";

abstract contract CMTATBaseCommon is
    // Core
    VersionModule,
    ERC20MintModule,
    ERC20BurnModule,
    ERC20BaseModule,
    TokenAttributeModule,
    // Extension
    ERC20EnforcementModule,
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
    * @inheritdoc TokenAttributeModule
    */
    function name() public view virtual override(ERC20Upgradeable, TokenAttributeModule)  returns (string memory) {
        return TokenAttributeModule.name();
    }

    /**
    * @inheritdoc TokenAttributeModule
    */
    function symbol() public view virtual override(ERC20Upgradeable, TokenAttributeModule) returns (string memory) {
        return TokenAttributeModule.symbol();
    }


    /* ============  State Functions ============ */
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable) returns (bool) {
         address from = _msgSender();
        _checkTransferred(address(0), from, to, value);
        ERC20Upgradeable._transfer(from, to, value);
        return true;
    }
    /**
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
    /* ==== Mint and Burn Operations ==== */
    
    /**
    * @dev
    * Mint path
    * Check if the mint is valid
    * @inheritdoc ERC20MintModuleInternal
    */
    function _mintOverride(address account, uint256 value) internal virtual override(ERC20MintModuleInternal) {
        _checkTransferred(_msgSender(), address(0), account, value);
        ERC20MintModuleInternal._mintOverride(account, value);
    }

    /**
    * @dev
    * Burn path
    * Check if the burn is valid
    * @inheritdoc ERC20BurnModuleInternal
    */
    function _burnOverride(address account, uint256 value) internal virtual override(ERC20BurnModuleInternal) {
        _checkTransferred(_msgSender(),  account, address(0), value);
        ERC20BurnModuleInternal._burnOverride(account, value);
    }

    /**
    * @dev
    * Minter-initiated transfer path
    * Check if a minter transfer is valid
    * @inheritdoc ERC20MintModuleInternal
    */
    function _minterTransferOverride(address from, address to, uint256 value) internal virtual override(ERC20MintModuleInternal) {
        _checkTransferred(_msgSender(), from, to, value);
        ERC20MintModuleInternal._minterTransferOverride(from, to, value);
    }
}
