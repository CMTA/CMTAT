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
     * - Emitted by the allowance-consuming entry points: `transferFrom` (ERC20BaseModule),
     *   `burnFrom` (ERC20CrossChainModule), and `forcedTransfer` (ERC20EnforcementModule) when the
     *   latter reduces a finite owner→recipient allowance.
     * - WARNING - this event does NOT, by itself, imply that the on-chain allowance decreased.
     *   It is emitted on *every* successful allowance-consuming `transferFrom` / `burnFrom`,
     *   including when the allowance is infinite (`type(uint256).max`), in which case OpenZeppelin
     *   leaves the allowance unchanged. `value` is the amount used, not the size of any reduction.
     * - For `forcedTransfer`, `Spend` is emitted only when the allowance is finite and non-zero
     *   (the case where it is actually reduced), and `value` is the amount taken from it (capped by
     *   the allowance). `forcedTransfer` does not emit `Approval` for that reduction.
     * - To reconstruct the current allowance, read `allowance(owner, spender)` — never accumulate
     *   `Spend` (or `Approval`) events.
     * - Event ordering differs between the emit sites: `transferFrom` emits `Transfer` then
     *   `Spend`; `burnFrom` emits `Spend` then `Transfer` then `BurnFrom`. See
     *   [doc/technical/allowance-spend-event.md](../../../doc/technical/allowance-spend-event.md).
     * @param account The owner of the tokens whose allowance is being spent.
     * @param spender The address authorized to spend the tokens.
     * @param value The amount of allowance used (not necessarily the amount by which it decreased).
     */
    event Spend(address indexed account, address indexed spender, uint256 value);
}

