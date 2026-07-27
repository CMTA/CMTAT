//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
 * @title IERC20Allowance
 * @notice Interface for emitting spend-related events in ERC-20 based tokens.
 */
interface IERC20Allowance {
   /* ============ Events ============ */
    /**
     * @notice Emitted when a `spender` uses a `value` amount of an `account`'s allowance.
     * @dev
     * - Similar in intent to the ERC-20 `Approval` event, but signals *consumption* of an
     *   allowance rather than its granting.
     * - Emitted by the allowance-consuming entry points: `transferFrom` (ERC20BaseModule) and
     *   `burnFrom` (ERC20CrossChainModule).
     * - WARNING - this event does NOT, by itself, imply that the on-chain allowance decreased.
     *   It is emitted on *every* successful allowance-consuming call, including when the allowance
     *   is infinite (`type(uint256).max`), in which case OpenZeppelin leaves the allowance
     *   unchanged. `value` is the amount used, not the size of any reduction.
     * - WARNING - `Spend` is NOT a complete ledger of allowance movement. `forcedTransfer`
     *   (ERC20EnforcementModule) can consume an owner→recipient allowance without emitting `Spend`
     *   (or `Approval`). To reconstruct the current allowance, read `allowance(owner, spender)` —
     *   never accumulate `Spend` (or `Approval`) events.
     * - Event ordering differs between the two emit sites: `transferFrom` emits `Transfer` then
     *   `Spend`; `burnFrom` emits `Spend` then `Transfer` then `BurnFrom`. See
     *   [doc/technical/allowance-spend-event.md](../../../doc/technical/allowance-spend-event.md).
     * @param account The owner of the tokens whose allowance is being spent.
     * @param spender The address authorized to spend the tokens.
     * @param value The amount of allowance used (not necessarily the amount by which it decreased).
     */
    event Spend(address indexed account, address indexed spender, uint256 value);
}

