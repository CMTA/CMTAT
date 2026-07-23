//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @title Holder List Module Interface
* @notice Maintain on-chain the list of the addresses holding a non-zero balance
* @dev The holder set is a view over `balanceOf`: an address belongs to it if and only if
* its balance is non-zero. {holderCount}, {holderByIndex}, {isHolder}, {holders} and
* {holdersInRange} follow the naming of the fungible holder-enumeration specification.
*/
interface IHolderListModule {
    /* ============ Errors ============ */
    /**
     * @notice A requested index is past the end of the holder set
     * @dev Raised by {holderByIndex} when `index >= holderCount()`, and by {holdersInRange}
     * when `toIndex > holderCount()`. The second parameter is always the current holder count,
     * so a caller that raced a concurrent removal learns the new bound from the revert data.
     * @param index The index that was requested
     * @param holderCount The current number of holders, i.e. the exclusive upper bound
     */
    error CMTAT_HolderListModule_IndexOutOfBounds(uint256 index, uint256 holderCount);
    /**
     * @notice A range is malformed because its lower bound exceeds its upper bound
     * @dev Distinct from {CMTAT_HolderListModule_IndexOutOfBounds}: the range is not past the
     * end of the set, it is internally inconsistent, so neither argument is a holder count.
     * @param fromIndex The requested lower bound, inclusive
     * @param toIndex The requested upper bound, exclusive
     */
    error CMTAT_HolderListModule_InvalidRange(uint256 fromIndex, uint256 toIndex);

    /* ============ Events ============ */
    /**
     * @notice Emitted when an address becomes a holder, its balance moving from zero to non-zero
     * @param holder The address added to the holder list
     */
    event HolderAdded(address indexed holder);
    /**
     * @notice Emitted when an address stops being a holder, its balance moving from non-zero to zero
     * @param holder The address removed from the holder list
     */
    event HolderRemoved(address indexed holder);

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
     * state changes. See {holdersInRange} for the implications on pagination.
     * @param index The position in the holder set, in `[0, holderCount())`
     * @return The holder address at `index`
     */
    function holderByIndex(uint256 index) external view returns (address);

    /**
     * @notice Returns the whole holder list in a single call
     * @dev Unbounded: the cost grows with {holderCount} and this call will run out of gas once
     * the holder list is large enough. It is intended for off-chain `eth_call`. On-chain callers,
     * and any caller that cannot bound the holder count, MUST use {holdersInRange} instead.
     * The returned array is ordered as {holderByIndex}: `holders()[i] == holderByIndex(i)` within
     * a single block, and `holders()` is exactly `holdersInRange(0, holderCount())`.
     * @return The full list of holder addresses
     */
    function holders() external view returns (address[] memory);

    /**
     * @notice Returns the contiguous window of holders at indices `[fromIndex, toIndex)`
     * @dev Half-open: `fromIndex` inclusive, `toIndex` exclusive, so the returned length is
     * exactly `toIndex - fromIndex`. The window is a slice of the sequence {holderByIndex}
     * enumerates: `holdersInRange(f, t)[i] == holderByIndex(f + i)` within a single block.
     *
     * Reverts with {CMTAT_HolderListModule_InvalidRange} if `fromIndex > toIndex`, and with
     * {CMTAT_HolderListModule_IndexOutOfBounds} if `toIndex > holderCount()`. The malformed-range
     * check is evaluated first, so an inverted range always yields {CMTAT_HolderListModule_InvalidRange}
     * regardless of where the bounds fall. `fromIndex == toIndex` returns an empty array without
     * reverting, including when both equal `holderCount()` — the natural terminating condition of
     * a paging loop.
     *
     * The underlying set is unordered and a removal moves the last holder into the freed slot, so
     * windows read across several blocks may miss a holder or return one twice. Read the whole set
     * at a fixed block (`eth_call` at a block number) if a consistent snapshot is required.
     * @param fromIndex The index of the first holder to return, inclusive
     * @param toIndex The index one past the last holder to return, exclusive
     * @return window The holders at indices `fromIndex` through `toIndex - 1`, in enumeration order
     */
    function holdersInRange(uint256 fromIndex, uint256 toIndex) external view returns (address[] memory window);
}
