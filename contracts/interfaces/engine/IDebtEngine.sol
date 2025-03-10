// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import {ICMTATDebt} from "../tokenization/ICMTAT.sol";

/*
* @dev minimum interface to define a DebtEngine
*/
interface IDebtEngine is ICMTATDebt {
    // nothing more
}
