// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== Module === */
import {DebtModule, DebtEngineModule} from "./wrapper/options/DebtEngineModule.sol";
import {CMTATBaseRuleEngine} from "./1_CMTATBaseRuleEngine.sol";
/**
* @title Extend CMTAT Base with option modules
*/
abstract contract CMTATBaseDebt is CMTATBaseRuleEngine, DebtEngineModule {
   function _authorizeDebtManagement() internal virtual override(DebtModule) onlyRole(DEBT_ROLE){}
}
