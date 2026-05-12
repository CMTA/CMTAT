// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {DebtModule} from "./wrapper/options/DebtModule.sol";
import {CMTATBaseRuleEngine} from "./2_CMTATBaseRuleEngine.sol";
import {CMTATBaseCommon} from "./0_CMTATBaseCommon.sol";
import {CMTATBaseSnapshot} from "./0_CMTATBaseSnapshot.sol";
import {SnapshotEngineModule} from "./wrapper/extensions/SnapshotEngineModule.sol";
/**
* @title Extend CMTAT Base with option modules
*/
abstract contract CMTATBaseDebt is CMTATBaseRuleEngine, DebtModule, CMTATBaseSnapshot {
   function approve(address spender, uint256 value)
      public virtual override(ERC20Upgradeable, CMTATBaseRuleEngine) returns (bool)
   {
      return CMTATBaseRuleEngine.approve(spender, value);
   }

   function transfer(address to, uint256 value)
      public virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (bool)
   {
      return CMTATBaseCommon.transfer(to, value);
   }

   function transferFrom(address from, address to, uint256 value)
      public virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (bool)
   {
      return CMTATBaseCommon.transferFrom(from, to, value);
   }

   function decimals()
      public view virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (uint8)
   {
      return CMTATBaseCommon.decimals();
   }

   function name()
      public view virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (string memory)
   {
      return CMTATBaseCommon.name();
   }

   function symbol()
      public view virtual override(ERC20Upgradeable, CMTATBaseCommon) returns (string memory)
   {
      return CMTATBaseCommon.symbol();
   }

   function _update(address from, address to, uint256 amount)
      internal virtual override(ERC20Upgradeable, CMTATBaseSnapshot)
   {
      CMTATBaseSnapshot._update(from, to, amount);
   }

   function _authorizeDebtManagement() internal virtual override(DebtModule) onlyRole(DEBT_ROLE){}

   function _authorizeSnapshots() internal virtual override(SnapshotEngineModule) onlyRole(SNAPSHOOTER_ROLE) {}
}
