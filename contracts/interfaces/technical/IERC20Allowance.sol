   //SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @notice Interface to emit spend events
*/
interface IERC20Allowance {
   /* ============ Events ============ */
    /**
    * @notice Emitted when the specified `spender` spends the specified `value` tokens owned by the specified `owner` reducing the corresponding allowance.
    * @dev The allowance can be also "spend" with the function BurnFrom, but in this case, the emitted event is BurnFrom.
    */
    event Spend(address indexed owner, address indexed spender, uint256 value);
}

