//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @title IERC20Allowance
 * @notice Interface for emitting spend-related events in ERC-20 based tokens.
 */
interface IERC20Allowance {
   /* ============ Events ============ */
    /**
     * @notice Emitted when a `spender` spends a `value` amount of tokens on behalf of an `account`.
     * @dev 
     * - This event is similar in semantics to the ERC-20 `Approval` event.
     * Approval(address indexed _owner, address indexed _spender, uint256 _value)
     * - It represents a reduction in the spender’s allowance granted by the account.
     * - Can also be used for function which uses the allowance, e.g.`burnFrom
     * @param account The owner of the tokens whose allowance is being spent.
     * @param spender The address authorized to spend the tokens.
     * @param value The amount of tokens that were spent.
     */
    event Spend(address indexed account, address indexed spender, uint256 value);
}

