//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
 * @dev Optional hook interface for rules that need to update their own state
 * on token transfer/mint/burn intents.
 */
interface IRuleTransferHook {
    function transferred(address spender, address from, address to, uint256 value) external;
}

