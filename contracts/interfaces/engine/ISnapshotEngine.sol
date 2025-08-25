// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev minimum interface to define a SnapshotEngine
*/
interface ISnapshotEngine {
   /**
    * @notice Records balance and total supply snapshots before any token transfer occurs.
    * @dev This function should be called inside the {__update} hook so that
    * snapshots are updated prior to any state changes from {_mint}, {_burn}, or {_transfer}.
    * It ensures historical balances and total supply remain accurate for snapshot queries.
    *
    * @param from The address tokens are being transferred from (zero address if minting).
    * @param to The address tokens are being transferred to (zero address if burning).
    * @param balanceFrom The current balance of `from` before the transfer (used to update snapshot).
    * @param balanceTo The current balance of `to` before the transfer (used to update snapshot).
    * @param totalSupply The current total supply before the transfer (used to update snapshot).
    */
    function operateOnTransfer(address from, address to, uint256 balanceFrom, uint256 balanceTo, uint256 totalSupply) external;
}

/**
 * @title IERC20BatchBalance
 * @notice Interface to query multiple account balances and the total supply in a single call.
 */
interface IERC20BatchBalance {
     /**
     * @notice Returns the balances of multiple addresses and the total token supply.
     * @param addresses The list of addresses to retrieve balances for.
     * @return balances An array of token balances corresponding to each address in the input list.
     * @return totalSupply_ The total supply of the token.
     * @dev 
     * - Useful for scenarios like dividend distribution or performing on-chain balance snapshots.
     * - Optimizes gas costs by aggregating balance reads into one function call.
     */
    function batchBalanceOf(address[] calldata addresses) external view 
    returns(uint256[] memory balances , uint256 totalSupply_);
}