// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Wrapper === */
import {SnapshotEngineModule} from "./wrapper/extensions/SnapshotEngineModule.sol";
/* ==== Interface === */
import {ISnapshotEngine} from "../interfaces/engine/ISnapshotEngine.sol";

/**
* @title Snapshot engine mixin
* @dev Pure mixin: provides _update logic with snapshot engine integration.
* Access control for setSnapshotEngine (_authorizeSnapshots) is left abstract
* and must be implemented by the inheriting contract.
*/
abstract contract CMTATBaseSnapshot is ERC20Upgradeable, SnapshotEngineModule {
    function _update(address from, address to, uint256 amount) internal virtual override(ERC20Upgradeable) {
        ISnapshotEngine snapshotEngineLocal = snapshotEngine();
        if (address(snapshotEngineLocal) != address(0)) {
            uint256 fromBalanceBefore = balanceOf(from);
            uint256 toBalanceBefore = balanceOf(to);
            uint256 totalSupplyBefore = totalSupply();
            ERC20Upgradeable._update(from, to, amount);
            snapshotEngineLocal.operateOnTransfer(from, to, fromBalanceBefore, toBalanceBefore, totalSupplyBefore);
        } else {
            ERC20Upgradeable._update(from, to, amount);
        }
    }
}
