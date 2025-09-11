//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Engine === */
import {IDebtEngine, ICMTATDebt, ICMTATCreditEvents} from "../../../interfaces/engine/IDebtEngine.sol";
/* ==== Module === */
import {DebtModule} from "./DebtModule.sol";
/**
 * @title Debt Engine module
 * @dev 
 *
 * Retrieve debt and creditEvents information from a debtEngine
 */
abstract contract DebtEngineModule is DebtModule {
    /* ============ Events ============ */
    /**
    * @notice Emitted when a new DebtEngine is set.
    * @dev Indicates that the contract will delegate debt logic to a new external engine.
    * @param newDebtEngine The address of the new debt engine contract.
    */
    event DebtEngine(IDebtEngine indexed newDebtEngine);

    /* ============ Error ============ */
    error CMTAT_DebtEngineModule_SameValue();


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/  

    /* ============  State Restricted Functions ============ */
    /**
    * @notice Sets a new external DebtEngine contract to delegate debt logic.
    * @dev Only callable by accounts with the `DEBT_ROLE`.
    * Emits a {DebtEngine} event upon successful update.
    * @param debtEngine_ The address of the new DebtEngine contract.
    * @custom:access-control
    * - the caller must have the `DEBT_ROLE`.
    */
    function setDebtEngine(
        IDebtEngine debtEngine_
    ) public virtual onlyDebtManager {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        require($._debtEngine != debtEngine_, CMTAT_DebtEngineModule_SameValue());
        _setDebtEngine($, debtEngine_);
    }

    /* ============ View functions ============ */
    /**
    * @notice Returns the current credit events information.
    * @dev Delegates to the external DebtEngine if set; otherwise returns the base implementation from DebtModule.
    * @return creditEvents_ The current credit events structure.
    * @inheritdoc ICMTATCreditEvents
    */
    function creditEvents() public view virtual override(DebtModule) returns(CreditEvents memory creditEvents_){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        if(address($._debtEngine) != address(0)){
            creditEvents_ =  $._debtEngine.creditEvents();
        } else {
            creditEvents_= DebtModule.creditEvents();
        }
    }

    /**
    * @notice Returns the current debt information.
    * @dev Delegates to the external DebtEngine if set; otherwise returns the base implementation from DebtModule.
    * @return debtInformation_ The current debt data structure.
    * @inheritdoc DebtModule
    */
    function debt() public view virtual override(DebtModule) returns(DebtInformation memory debtInformation_){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        if(address($._debtEngine) != address(0)){
            debtInformation_ =  $._debtEngine.debt();
        } else {
            debtInformation_ = DebtModule.debt();
        }
    }

    /**
    * @notice Returns the address of the currently active DebtEngine.
    * @return debtEngine_ The contract address of the debt engine in use.
    */
    function debtEngine() public view virtual returns (IDebtEngine debtEngine_) {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        return $._debtEngine;
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