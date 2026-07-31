// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {CMTATBaseERC20CrossChain} from "./5_CMTATBaseERC20CrossChain.sol";
import {CMTATBaseERC7551Enforcement} from "./7_CMTATBaseERC7551Enforcement.sol";
import {HolderListModule} from "./wrapper/options/HolderListModule.sol";
/* ==== Interface and other library === */
import {IHolderListModule} from "../interfaces/modules/IHolderListModule.sol";

/**
 * @title Extend the CMTAT standard path with the on-chain holder list
 * @dev Same modules as the CMTAT standard version, plus {HolderListModule}.
 *
 * {HolderListModule} inherits {ERC20Upgradeable}, so the ERC-20 entry points are reachable
 * through two branches of the inheritance graph and have to be disambiguated here. They all
 * resolve to {CMTATBaseERC7551Enforcement}, which keeps the validation performed by the
 * standard path. Only {_update} resolves to {HolderListModule}, which calls `super._update`
 * and therefore still reaches {ERC20Upgradeable-_update}.
 */
abstract contract CMTATBaseHolderList is CMTATBaseERC7551Enforcement, HolderListModule {
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ State functions ============ */
    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function transfer(address to, uint256 value)
        public virtual
        override(ERC20Upgradeable, CMTATBaseERC7551Enforcement)
        returns (bool)
    {
        return CMTATBaseERC7551Enforcement.transfer(to, value);
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function transferFrom(address from, address to, uint256 value)
        public virtual
        override(ERC20Upgradeable, CMTATBaseERC7551Enforcement)
        returns (bool)
    {
        return CMTATBaseERC7551Enforcement.transferFrom(from, to, value);
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function approve(address spender, uint256 value)
        public virtual
        override(ERC20Upgradeable, CMTATBaseERC7551Enforcement)
        returns (bool)
    {
        return CMTATBaseERC7551Enforcement.approve(spender, value);
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function name()
        public view virtual
        override(ERC20Upgradeable, CMTATBaseERC7551Enforcement)
        returns (string memory)
    {
        return CMTATBaseERC7551Enforcement.name();
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function symbol()
        public view virtual
        override(ERC20Upgradeable, CMTATBaseERC7551Enforcement)
        returns (string memory)
    {
        return CMTATBaseERC7551Enforcement.symbol();
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function decimals()
        public view virtual
        override(ERC20Upgradeable, CMTATBaseERC7551Enforcement)
        returns (uint8)
    {
        return CMTATBaseERC7551Enforcement.decimals();
    }

    function supportsInterface(bytes4 interfaceId)
        public view virtual
        override(CMTATBaseERC20CrossChain)
        returns (bool)
    {
        return interfaceId == type(IHolderListModule).interfaceId
            || CMTATBaseERC20CrossChain.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc HolderListModule
    */
    function _update(address from, address to, uint256 value)
        internal virtual
        override(ERC20Upgradeable, HolderListModule)
    {
        HolderListModule._update(from, to, value);
    }

    /*//////////////////////////////////////////////////////////////
                            ERC2771 MODULE
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function _msgSender()
        internal view virtual
        override(ContextUpgradeable, CMTATBaseERC7551Enforcement)
        returns (address sender)
    {
        return CMTATBaseERC7551Enforcement._msgSender();
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function _msgData()
        internal view virtual
        override(ContextUpgradeable, CMTATBaseERC7551Enforcement)
        returns (bytes calldata)
    {
        return CMTATBaseERC7551Enforcement._msgData();
    }

    /**
    * @inheritdoc CMTATBaseERC7551Enforcement
    */
    function _contextSuffixLength()
        internal view virtual
        override(ContextUpgradeable, CMTATBaseERC7551Enforcement)
        returns (uint256)
    {
        return CMTATBaseERC7551Enforcement._contextSuffixLength();
    }
}
