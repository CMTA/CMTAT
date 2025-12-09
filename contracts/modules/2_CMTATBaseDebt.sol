// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== Module === */
import {DebtModule} from "./wrapper/options/DebtEngineModule.sol";
import {CMTATBaseRuleEngine} from "./1_CMTATBaseRuleEngine.sol";
/**
* @title Extend CMTAT Base with option modules
*/
abstract contract CMTATBaseDebt is CMTATBaseRuleEngine, DebtModule {
   function _authorizeDebtManagement() internal virtual override(DebtModule) onlyRole(DEBT_ROLE){}
}
