//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
/* ==== Module === */
import {IDebtEngine, DebtEngineModule, ICMTATDebt} from "./wrapper/options/DebtEngineModule.sol";
import {DebtEngineModule, DebtModule, ICMTATDebt} from "./wrapper/options/DebtEngineModule.sol";
import {CMTATBaseRuleEngine} from "./1_CMTATBaseRuleEngine.sol";
import {CMTATBaseCommon, AccessControlUpgradeable, AuthorizationModule} from "./0_CMTATBaseCommon.sol";
/**
* @title Extend CMTAT Base with option modules
*/
abstract contract CMTATBaseDebt is CMTATBaseRuleEngine, DebtEngineModule {
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable, CMTATBaseRuleEngine) returns (bool) {
        return CMTATBaseRuleEngine.hasRole(role, account);
    }
   
}
