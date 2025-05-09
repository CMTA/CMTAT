//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
/* ==== Module === */
import {DebtEngineModule, ICMTATDebt} from "./options/DebtEngineModuleOption.sol";
import {ERC20CrossChainModule} from "./options/ERC20CrossChainModule.sol";


/**
* @title Extend CMTAT Base
*/
abstract contract CMTAT_BASE_EXTEND is  ERC20CrossChainModule {
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
