// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;
import {ICMTATDebt, ICMTATCreditEvents} from "../tokenization/ICMTAT.sol";

/*
* @dev minimum interface to define a DebtEngine
*/
interface IDebtEngine is ICMTATDebt, ICMTATCreditEvents {
    // nothing more
}
