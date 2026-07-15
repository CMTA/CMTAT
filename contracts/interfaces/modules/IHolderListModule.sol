//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @title Holder List Module Interface
* @notice Maintain on-chain the list of the addresses holding a non-zero balance
* @dev The holder set is a view over `balanceOf`: an address belongs to it if and only if
* its balance is non-zero. {holderCount}, {holderByIndex}, {isHolder} and {holders} follow
* the naming of the fungible holder-enumeration specification; {holdersByPage} is an
* additional paginated read specific to CMTAT.
*/
interface IHolderListModule {
    /* ============ Errors ============ */
    /**
     * @notice The requested index is greater than or equal to the number of holders
     */
    error CMTAT_HolderListModule_IndexOutOfBounds(uint256 index, uint256 holderCount);
    /**
     * @notice The requested offset is strictly greater than the number of holders
     */
    error CMTAT_HolderListModule_OffsetOutOfBounds(uint256 offset, uint256 holderCount);

    /* ============ Events ============ */
    /**
     * @notice Emitted when an address becomes a holder, its balance moving from zero to non-zero
     * @param account The address added to the holder list
     */
    event HolderAdded(address indexed account);
    /**
     * @notice Emitted when an address stops being a holder, its balance moving from non-zero to zero
     * @param account The address removed from the holder list
     */
    event HolderRemoved(address indexed account);

    /* ============ Functions ============ */
    /**
     * @notice Returns the number of addresses currently holding a non-zero balance
     * @return The holder count
     */
    function holderCount() external view returns (uint256);

    /**
     * @notice Returns whether an account currently holds a non-zero balance
     * @param account The address to check
     * @return True if the address is a holder, false otherwise
     */
    function isHolder(address account) external view returns (bool);

    /**
     * @notice Returns the holder stored at a given index
     * @dev Reverts with {CMTAT_HolderListModule_IndexOutOfBounds} if `index >= holderCount()`.
     * Holders are stored in an unordered set: the index of a given holder is not stable across
     * state changes. See {holdersByPage} for the implications on pagination.
     * @param index The position in the holder set, in `[0, holderCount())`
     * @return The holder address at `index`
     */
    function holderByIndex(uint256 index) external view returns (address);

    /**
     * @notice Returns the whole holder list in a single call
     * @dev Unbounded: the cost grows with {holderCount} and this call will run out of gas once
     * the holder list is large enough. It is intended for off-chain `eth_call`. On-chain callers,
     * and any caller that cannot bound the holder count, MUST use {holdersByPage} instead.
     * The returned array is ordered as {holderByIndex}: `holders()[i] == holderByIndex(i)` within
     * a single block.
     * @return The full list of holder addresses
     */
    function holders() external view returns (address[] memory);

    /**
     * @notice Returns a page of the holder list
     * @dev Returns `min(limit, holderCount() - offset)` addresses starting at `offset`.
     * Reverts with {CMTAT_HolderListModule_OffsetOutOfBounds} if `offset > holderCount()`;
     * an `offset` equal to `holderCount()` returns an empty page, so a paging loop
     * terminates without a special case.
     *
     * The underlying set is unordered and a removal moves the last holder into the freed
     * slot. A page read while transfers are mined may therefore miss a holder or return
     * one twice. Read the whole list at a fixed block (`eth_call` at a block number) if a
     * consistent snapshot is required.
     * @param offset The index of the first holder to return
     * @param limit The maximum number of holders to return
     * @return holdersPage The requested page of holder addresses
     */
    function holdersByPage(uint256 offset, uint256 limit) external view returns (address[] memory holdersPage);
}
