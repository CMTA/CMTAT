// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {CMTATBaseERC2771} from "./6_CMTATBaseERC2771.sol";
import {CMTATBaseERC20CrossChain} from "./5_CMTATBaseERC20CrossChain.sol";
import {CMTATBaseSnapshot} from "./0_CMTATBaseSnapshot.sol";
import {SnapshotEngineModule} from "./wrapper/extensions/SnapshotEngineModule.sol";

/**
* @title Extend CMTATBaseERC2771 with snapshot engine support
*/
abstract contract CMTATBaseERC2771Snapshot is CMTATBaseERC2771, CMTATBaseSnapshot {

    /*//////////////////////////////////////////////////////////////
                  ERC-20 / CMTATBaseSnapshot disambiguation
    //////////////////////////////////////////////////////////////*/

    function _update(address from, address to, uint256 amount)
        internal virtual override(ERC20Upgradeable, CMTATBaseSnapshot)
    {
        CMTATBaseSnapshot._update(from, to, amount);
    }

    function transfer(address to, uint256 value)
        public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool)
    {
        return CMTATBaseERC20CrossChain.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value)
        public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool)
    {
        return CMTATBaseERC20CrossChain.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value)
        public virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (bool)
    {
        return CMTATBaseERC20CrossChain.approve(spender, value);
    }

    function decimals()
        public view virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (uint8)
    {
        return CMTATBaseERC20CrossChain.decimals();
    }

    function name()
        public view virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (string memory)
    {
        return CMTATBaseERC20CrossChain.name();
    }

    function symbol()
        public view virtual override(ERC20Upgradeable, CMTATBaseERC20CrossChain) returns (string memory)
    {
        return CMTATBaseERC20CrossChain.symbol();
    }

    /*//////////////////////////////////////////////////////////////
                  ERC2771 / Context disambiguation
    //////////////////////////////////////////////////////////////*/

    function _msgSender()
        internal virtual view override(CMTATBaseERC2771, ContextUpgradeable) returns (address sender)
    {
        return CMTATBaseERC2771._msgSender();
    }

    function _msgData()
        internal virtual view override(CMTATBaseERC2771, ContextUpgradeable) returns (bytes calldata)
    {
        return CMTATBaseERC2771._msgData();
    }

    function _contextSuffixLength()
        internal virtual view override(CMTATBaseERC2771, ContextUpgradeable) returns (uint256)
    {
        return CMTATBaseERC2771._contextSuffixLength();
    }

    /*//////////////////////////////////////////////////////////////
                        Access Control
    //////////////////////////////////////////////////////////////*/

    function _authorizeSnapshots() internal virtual override(SnapshotEngineModule) onlyRole(SNAPSHOOTER_ROLE) {}
}
