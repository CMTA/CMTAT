//SPDX-License-Identifier: MPL-2.0
import {ICMTATDebt} from "../tokenization/ICMTAT.sol";

pragma solidity ^0.8.20;
/**
* @notice interface to represent DebtModule
*/
interface IDebtModule is ICMTATDebt {
    /* ============ Events ============ */
     // No paramater to reduce contract size
    event Debt();
    event DebtInstrumentEvent();

    /* ============ Functions ============ */
    /**
     * @notice Set only the instrument
     */
    function setDebtInstrument(
          ICMTATDebt.DebtInstrument calldata debtInstrument_
    ) external;
    
    /**
     * @notice Set the debt
     */
    function setDebt(
          ICMTATDebt.DebtInformation calldata debt_
    ) external;
}


