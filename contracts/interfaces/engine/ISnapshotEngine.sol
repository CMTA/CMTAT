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


interface IERC20BatchBalance {
    /**
    * @param addresses list of address to know their balance
    * @return balances ,totalSupply array with balance for each address, totalSupply
    * @dev useful to distribute dividend and to perform on-chain snapshot
    */
    function batchBalanceOf(address[] calldata addresses) external view 
    returns(uint256[] memory balances , uint256 totalSupply_);
}