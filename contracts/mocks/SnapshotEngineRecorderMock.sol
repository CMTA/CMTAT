//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

import {ISnapshotEngine} from "../interfaces/engine/ISnapshotEngine.sol";

/**
* @title A SnapshotEngine that only counts the transfer callbacks it receives.
* @dev TESTING ONLY. Lets a test check whether a token calls its SnapshotEngine at all.
*/
contract SnapshotEngineRecorderMock is ISnapshotEngine {
    /// @notice Number of `operateOnTransfer` callbacks received.
    uint256 public callCount;

    function operateOnTransfer(address, address, uint256, uint256, uint256) external override {
        callCount += 1;
    }
}
