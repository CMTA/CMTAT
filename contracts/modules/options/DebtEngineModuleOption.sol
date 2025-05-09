//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../security/AuthorizationModule.sol";
/* ==== Engine === */
import {IDebtEngine, ICMTATDebt} from "../../interfaces/engine/IDebtEngine.sol";
import {DebtEngineModule} from "../wrapper/extensions/DebtEngineModule.sol";
/**
 * @title Debt module
 * @dev 
 *
 * Retrieve debt and creditEvents information from a debtEngine
 */
abstract contract DebtEngineModuleOption is DebtEngineModule {
    /**
     * @notice Set the debt
     */
    function setDebt(
          ICMTATDebt.DebtBase calldata debt_
    ) external onlyRole(DEBT_ROLE) {
        DebtEngineModuleStorage storage $ = _getDebtEngineModuleStorage();
        $._debt = debt_;
    }
    function debt() public view virtual override(DebtEngineModule) returns(DebtBase memory debtBaseResult){
        DebtEngineModuleStorage storage $ = _getDebtEngineModuleStorage();
        if(address($._debtEngine) != address(0)){
            debtBaseResult =  $._debtEngine.debt();
        } else {
            debtBaseResult = $._debt;
        }
    }
}
