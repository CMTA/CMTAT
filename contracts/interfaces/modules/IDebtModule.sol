//SPDX-License-Identifier: MPL-2.0
import {ICMTATDebt, ICMTATCreditEvents} from "../tokenization/ICMTAT.sol";

pragma solidity ^0.8.20;
/**
* @notice interface to represent DebtModule (debt information and credit events.)
*/
interface IDebtModule is ICMTATDebt, ICMTATCreditEvents {
    /* ============ Events ============ */
    // This interface emits lightweight log events to minimize contract size.
    // Add the suffixe `log`to avoid conflict with the view function `CreditEvents()`
    /**
     * @notice Emitted when the whole debt information are updated
     */
    event DebtLogEvent();

    /**
     * @notice Emitted when the credit events are updated.
     */
    event CreditEventsLogEvent();
    /**
    * @notice Emitted when only the debt instrument is updated
    */
    event DebtInstrumentLogEvent();

    /* ============ Functions ============ */
    /**
     * @notice Sets only the debt instrument data.
     * @param debtInstrument_ The debt instrument to store.
     */
    function setDebtInstrument(
          ICMTATDebt.DebtInstrument calldata debtInstrument_
    ) external;
    
    /**
     * @notice Sets the debt information.
     * @param debt_ The debt data to store.
     */
    function setDebt(
          ICMTATDebt.DebtInformation calldata debt_
    ) external;
    
    /**
     * @notice Sets the credit events information.
     * @param creditEvents_ The credit events to store.
     */
    function setCreditEvents(
       CreditEvents calldata creditEvents_
    ) external; 
}


