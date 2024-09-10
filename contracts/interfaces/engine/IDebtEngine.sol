// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import "./IDebtGlobal.sol";

/*
* @dev minimum interface to define a DebtEngine
*/
interface IDebtEngine is IDebtGlobal {
    /**
     * @dev Returns debt information
     */
    function debt() external view returns(IDebtGlobal.DebtBase memory);
    /**
     * @dev Returns credit events
     */
    function creditEvents() external view returns(IDebtGlobal.CreditEvents memory);
   
}
