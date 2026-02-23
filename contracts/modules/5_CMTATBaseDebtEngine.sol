// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== Module === */
import {DebtEngineModule} from "./wrapper/options/DebtEngineModule.sol";
import {CMTATBaseERC20CrossChain} from "./4_CMTATBaseERC20CrossChain.sol";
/**
* @title Extend CMTAT Base with option modules
*/
abstract contract CMTATBaseDebtEngine is DebtEngineModule, CMTATBaseERC20CrossChain {
   function _authorizeDebtEngineManagement() internal virtual override(DebtEngineModule) onlyRole(DEBT_ENGINE_ROLE){}
}