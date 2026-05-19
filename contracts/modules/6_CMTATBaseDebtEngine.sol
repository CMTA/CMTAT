// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {DebtEngineModule} from "./wrapper/options/DebtEngineModule.sol";
import {CMTATBaseERC20CrossChain} from "./5_CMTATBaseERC20CrossChain.sol";
import {CMTATBaseSnapshot} from "./0_CMTATBaseSnapshot.sol";
import {SnapshotEngineModule} from "./wrapper/extensions/SnapshotEngineModule.sol";

/**
* @title Extend CMTAT Base with DebtEngine module and snapshot engine support
*/
abstract contract CMTATBaseDebtEngine is DebtEngineModule, CMTATBaseERC20CrossChain, CMTATBaseSnapshot {

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
                        Access Control
    //////////////////////////////////////////////////////////////*/

    function _authorizeDebtEngineManagement() internal virtual override(DebtEngineModule) onlyRole(DEBT_ENGINE_ROLE) {}

    function _authorizeSnapshots() internal virtual override(SnapshotEngineModule) onlyRole(SNAPSHOOTER_ROLE) {}
}
