//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Engine === */
import {IDebtEngine, ICMTATDebt, ICMTATCreditEvents} from "../../../interfaces/engine/IDebtEngine.sol";
import {DebtModule} from "../extensions/DebtModule.sol";
/**
 * @title Debt module
 * @dev 
 *
 * Retrieve debt and creditEvents information from a debtEngine
 */
abstract contract DebtEngineModule is DebtModule, ICMTATCreditEvents {
    error CMTAT_DebtEngineModule_SameValue();
    /**
    * @dev Emitted when a rule engine is set.
    */
    event DebtEngine(IDebtEngine indexed newDebtEngine);

    /**
    * @inheritdoc ICMTATCreditEvents
    */
    function creditEvents() public view virtual returns(CreditEvents memory creditEventsResult){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        if(address($._debtEngine) != address(0)){
            creditEventsResult =  $._debtEngine.creditEvents();
        }
    }

    function debt() public view virtual override(DebtModule) returns(DebtBase memory debtBaseResult){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        //debtBaseResult = $._debt;
        if(address($._debtEngine) != address(0)){
            debtBaseResult =  $._debtEngine.debt();
        } else {
            debtBaseResult = DebtModule.debt();
        }
    }

    function debtEngine() public view virtual returns (IDebtEngine) {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        return $._debtEngine;
    }

    /* ============  Restricted Functions ============ */
    /*
    * @notice set a DebtEngine
    * 
    */
    function setDebtEngine(
        IDebtEngine debtEngine_
    ) external virtual onlyRole(DEBT_ROLE) {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        require($._debtEngine != debtEngine_, CMTAT_DebtEngineModule_SameValue());
        _setDebtEngine($, debtEngine_);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setDebtEngine(
        DebtModuleStorage storage $, IDebtEngine debtEngine_
    ) internal {
        $._debtEngine = debtEngine_;
        emit DebtEngine(debtEngine_);
    }
}
