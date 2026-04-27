// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {CMTATBaseAccessControl} from "./1_CMTATBaseAccessControl.sol";
import {CMTATBaseERC2771} from "./5_CMTATBaseERC2771.sol";
import {CMTATBaseERC20CrossChain} from "./4_CMTATBaseERC20CrossChain.sol";
import {ExtraInformationModule, ERC7551Module} from "./wrapper/options/ERC7551Module.sol";
import {ERC20EnforcementModule, ERC20EnforcementERC7551Module} from "./wrapper/options/ERC20EnforcementERC7551Module.sol";

/**
* @title Extend CMTAT Base with ERC7551Module and ERC20EnforcementERC7551Module
*/
abstract contract CMTATBaseERC7551 is CMTATBaseERC2771, ERC7551Module, ERC20EnforcementERC7551Module {
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control ==== */
    function _authorizeExtraInfoManagement() internal virtual override(CMTATBaseAccessControl, ExtraInformationModule) {
        CMTATBaseAccessControl._authorizeExtraInfoManagement();
    }

    function _authorizeERC20Enforcer() internal virtual override(CMTATBaseAccessControl, ERC20EnforcementModule) {
        CMTATBaseAccessControl._authorizeERC20Enforcer();
    }

    function _authorizeForcedTransfer() internal virtual override(CMTATBaseAccessControl, ERC20EnforcementModule) {
        CMTATBaseAccessControl._authorizeForcedTransfer();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== ERC2771 / Context disambiguation ==== */
    function _msgSender()
        internal virtual view
        override(CMTATBaseERC2771, ContextUpgradeable)
        returns (address sender)
    {
        return CMTATBaseERC2771._msgSender();
    }

    function _msgData()
        internal virtual view
        override(CMTATBaseERC2771, ContextUpgradeable)
        returns (bytes calldata)
    {
        return CMTATBaseERC2771._msgData();
    }

    function _contextSuffixLength()
        internal virtual view
        override(CMTATBaseERC2771, ContextUpgradeable)
        returns (uint256)
    {
        return CMTATBaseERC2771._contextSuffixLength();
    }

    /* ==== ERC-20 function disambiguation ==== */
    function transfer(address to, uint256 value)
        public virtual
        override(CMTATBaseERC20CrossChain, ERC20Upgradeable)
        returns (bool)
    {
        return CMTATBaseERC20CrossChain.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public virtual
        override(CMTATBaseERC20CrossChain, ERC20Upgradeable)
        returns (bool)
    {
        return CMTATBaseERC20CrossChain.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value)
        public virtual
        override(CMTATBaseERC20CrossChain, ERC20Upgradeable)
        returns (bool)
    {
        return CMTATBaseERC20CrossChain.approve(spender, value);
    }

    function name()
        public view virtual
        override(CMTATBaseERC20CrossChain, ERC20Upgradeable)
        returns (string memory)
    {
        return CMTATBaseERC20CrossChain.name();
    }

    function symbol()
        public view virtual
        override(CMTATBaseERC20CrossChain, ERC20Upgradeable)
        returns (string memory)
    {
        return CMTATBaseERC20CrossChain.symbol();
    }

    function decimals()
        public view virtual
        override(CMTATBaseERC20CrossChain, ERC20Upgradeable)
        returns (uint8)
    {
        return CMTATBaseERC20CrossChain.decimals();
    }

    function getFrozenTokens(address account)
        public view virtual
        override(ERC20EnforcementModule, ERC20EnforcementERC7551Module)
        returns (uint256 frozenBalance_)
    {
        return ERC20EnforcementERC7551Module.getFrozenTokens(account);
    }
}
