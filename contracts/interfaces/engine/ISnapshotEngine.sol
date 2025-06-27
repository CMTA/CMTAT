// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev minimum interface to define a SnapshotEngine
*/
interface ISnapshotEngine {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
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