//SPDX-License-Identifier: MPL-2.0
import {ICMTATDebt, ICMTATCreditEvents} from "../tokenization/ICMTAT.sol";
import {IDebtEngine} from "../engine/IDebtEngine.sol";
pragma solidity ^0.8.20;
/**
* @notice interface to represent DebtEngineModule (debt information and credit events.)
*/
interface IDebtEngineModule is ICMTATDebt, ICMTATCreditEvents {
        /* ============ Events ============ */
    /**
    * @notice Emitted when a new DebtEngine is set.
    * @dev Indicates that the contract will delegate debt logic to a new external engine.
    * @param newDebtEngine The address of the new debt engine contract.
    */
    event DebtEngine(IDebtEngine indexed newDebtEngine);

     /* ============ Error ============ */
    error CMTAT_DebtEngineModule_SameValue();

       /* ============ Functions ============ */
  function debtEngine() external view returns (IDebtEngine debtEngine_) ;

  function setDebtEngine(
        IDebtEngine debtEngine_
    ) external;
}


