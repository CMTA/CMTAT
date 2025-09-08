//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IERC165} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
/* ==== Module === */
import {CMTATBaseERC1404, ERC20Upgradeable} from "./2_CMTATBaseERC1404.sol";
import {CMTATBaseCommon} from "./0_CMTATBaseCommon.sol";
import {ERC20BurnModule, ERC20BurnModuleInternal} from "./wrapper/core/ERC20BurnModule.sol";
import {ERC20MintModule, ERC20MintModuleInternal} from "./wrapper/core/ERC20MintModule.sol";
/* ==== Interfaces === */
import {IERC7802} from "../interfaces/technical/IERC7802.sol";
import {IBurnFromERC20} from "../interfaces/technical/IMintBurnToken.sol";
import {ERC20CrossChain} from "./wrapper/options/ERC20CrossChain.sol";
/**
 * @title ERC20CrossChainModule (ERC-7802)
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract CMTATBaseERC20CrossChain is ERC20CrossChain,CMTATBaseERC1404  {
     /* ============  State Functions ============ */
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
    /**
    * @dev Check if the mint is valid
    */
    function _mintOverride(address account, uint256 value) internal virtual override(CMTATBaseCommon, ERC20MintModuleInternal) {
        _checkTransferred(address(0), address(0), account, value);
        ERC20MintModuleInternal._mintOverride(account, value);
    }

    /**
    * @dev Check if the burn is valid
    */
    function _burnOverride(address account, uint256 value) internal virtual override(CMTATBaseCommon, ERC20BurnModuleInternal) {
        _checkTransferred(address(0),  account, address(0), value);
        ERC20BurnModuleInternal._burnOverride(account, value);
    }

    /**
    * @dev Check if a minter transfer is valid
    */
    function _minterTransferOverride(address from, address to, uint256 value) internal virtual override(CMTATBaseCommon, ERC20MintModuleInternal) {
        _checkTransferred(address(0), from, to, value);
        ERC20MintModuleInternal._minterTransferOverride(from, to, value);
    }

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


    /* ============ View functions ============ */
    function supportsInterface(bytes4 _interfaceId) public view virtual override(AccessControlUpgradeable, ERC20CrossChain) returns (bool) {
        return  ERC20CrossChain.supportsInterface(_interfaceId)|| AccessControlUpgradeable.supportsInterface( _interfaceId);
    }

    
    function _checkTokenBridge(address caller) internal virtual override whenNotPaused {
        AccessControlUpgradeable._checkRole(CROSS_CHAIN_ROLE, caller); 
    }

    function _authorizeBurnFrom() internal virtual override onlyRole(BURNER_FROM_ROLE) whenNotPaused{}

    function _authorizeMint(CMTATBaseCommon, ERC20MintModule) internal virtual {
        CMTATBaseCommon._authorizeMint();
    }

    function _authorizeBurn() internal virtual override(CMTATBaseCommon, ERC20BurnModule) onlyRole(BURNER_ROLE){
        CMTATBaseCommon._authorizeBurn();
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20Upgradeable, CMTATBaseCommon) {
       return CMTATBaseCommon._update(from, to, amount);
    }
    
}