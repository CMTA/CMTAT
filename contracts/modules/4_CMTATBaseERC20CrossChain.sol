// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
/* ==== Module === */
import {CMTATBaseERC1404, CMTATBaseRuleEngine, ERC20Upgradeable} from "./3_CMTATBaseERC1404.sol";
import {CMTATBaseAccessControl} from "./1_CMTATBaseAccessControl.sol";
import {CMTATBaseCommon} from "./0_CMTATBaseCommon.sol";
import {ERC20BurnModule, ERC20BurnModuleInternal} from "./wrapper/core/ERC20BurnModule.sol";
import {ERC20MintModule, ERC20MintModuleInternal} from "./wrapper/core/ERC20MintModule.sol";
import {ERC20CrossChainModule} from "./wrapper/options/ERC20CrossChainModule.sol";
import {CCIPModule} from "./wrapper/options/CCIPModule.sol";

/**
 * @title Add support of ERC20CrossChainModule
 */
abstract contract CMTATBaseERC20CrossChain is ERC20CrossChainModule, CCIPModule, CMTATBaseERC1404  {
     /* ============  State Functions ============ */
        /**
    * @dev revert if the contract is in pause state
    */
    function approve(address spender, uint256 value) public virtual override(ERC20Upgradeable, CMTATBaseRuleEngine) returns (bool) {
        return CMTATBaseRuleEngine.approve(spender, value);
    }
    function transfer(address to, uint256 value) public virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (bool) {
         return CMTATBaseCommon.transfer(to, value);
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
        override(ERC20Upgradeable, CMTATBaseCommon)
        returns (bool)
    {
        return CMTATBaseCommon.transferFrom(from, to, value);
    }

    /* ============ View functions ============ */
  
    /**
    * @inheritdoc CMTATBaseCommon
    */
    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, CMTATBaseCommon)
        returns (uint8)
    {
        return CMTATBaseCommon.decimals();
    }


    /**
    * @inheritdoc CMTATBaseCommon
    */
    function name() public view virtual override(ERC20Upgradeable, CMTATBaseCommon)  returns (string memory) {
        return CMTATBaseCommon.name();
    }

    /**
    * @inheritdoc CMTATBaseCommon
    */
    function symbol() public view virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (string memory) {
        return CMTATBaseCommon.symbol();
    }

    function supportsInterface(bytes4 _interfaceId) public view virtual override(CMTATBaseAccessControl, ERC20CrossChainModule) returns (bool) {
        return  ERC20CrossChainModule.supportsInterface(_interfaceId)|| CMTATBaseAccessControl.supportsInterface( _interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Mint and Burn Operations ==== */
    /**
    * @dev Check if the mint is valid
    */
    function _mintOverride(address account, uint256 value) internal virtual override(CMTATBaseCommon, ERC20MintModuleInternal) {
        CMTATBaseRuleEngine._checkTransferred(address(0), address(0), account, value);
        CMTATBaseCommon._mintOverride(account, value);
    }

    /**
    * @dev Check if the burn is valid
    */
    function _burnOverride(address account, uint256 value) internal virtual override(CMTATBaseCommon, ERC20BurnModuleInternal) {
        CMTATBaseRuleEngine._checkTransferred(address(0),  account, address(0), value);
        CMTATBaseCommon._burnOverride(account, value);
    }

    /**
    * @dev Check if a minter transfer is valid
    */
    function _minterTransferOverride(address from, address to, uint256 value) internal virtual override(CMTATBaseCommon, ERC20MintModuleInternal) {
        CMTATBaseRuleEngine._checkTransferred(address(0), from, to, value);
        CMTATBaseCommon._minterTransferOverride(from, to, value);
    }

    /* ==== Access Control ==== */

    /** 
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function _authorizeCCIPSetAdmin() internal virtual override(CCIPModule) onlyRole(DEFAULT_ADMIN_ROLE) {}

    /** 
    * @dev 
    * A cross-chain bridge could call the OpenZeppelin function `renounceRole` to lose their privileges (CROSS_CHAIN_ROLE)
    * While it is not intended,this has no other effect than depriving the bridge of burn/mint tokens
    * An attacker could use this to disrupt minting/burning if they can get the bridge to execute calls. 
    * However, in this case, the bridge should still be considered compromised and not used again.
    * @custom:access-control
    * - the caller must have the `CROSS_CHAIN_ROLE`.
    */
    function _checkTokenBridge(address caller) internal virtual override(ERC20CrossChainModule) whenNotPaused {
        AccessControlUpgradeable._checkRole(CROSS_CHAIN_ROLE, caller); 
    }

    /** 
    * @custom:access-control
    * - the caller must have the `BURNER_FROM_ROLE`.
    * - We don't allow token holder to burn their own tokens if they don't have this role.
    */
    function _authorizeBurnFrom() internal virtual override(ERC20CrossChainModule) onlyRole(BURNER_FROM_ROLE) whenNotPaused{}

    /** 
    * @custom:access-control
    * - the caller must have the `BURNER_FROM_ROLE`.
    * - We don't allow token holder to burn their own tokens if they don't have this role.
    */
    function _authorizeSelfBurn() internal virtual override(ERC20CrossChainModule) onlyRole(BURNER_SELF_ROLE) whenNotPaused{}

    /* ==== ERC-20 OpenZeppelin ==== */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20Upgradeable, CMTATBaseCommon) {
       return CMTATBaseCommon._update(from, to, amount);
    }
}