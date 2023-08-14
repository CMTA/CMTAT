//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

library Errors {
    error InvalidTransfer(address from, address to, uint256 amount);
    // SnapshotModule
    error SnapshotScheduledInThePast(uint256 time, uint256 timestamp);
    error SnapshotTimestampBeforeLastSnapshot(uint256 time, uint256 lastSnapshotTimestamp);
    error SnapshotTimestampAfterNextSnapshot(uint256 time, uint256 nextSnapshotTimestamp);
    error SnapshotTimestampBeforePreviousSnapshot(uint256 time, uint256 previousSnapshotTimestamp);
    error SnapshotAlreadyExists();
    error SnapshotAlreadyDone();
    error SnapshotNotScheduled();
    error SnapshotNotFound();
    error SnapshotNeverScheduled();
    
    // Generic
    error AddressZeroNotAllowed();
    error DirectCallToImplementation();

    // ERC20BaseModule
    error WrongAllowance(uint256 allowance, uint256 currentAllowance);
    
    // BurnModule
    error CMTAT_BurnModule_EmptyAccounts();
    error CMTAT_BurnModule_AccountsValueslengthMismatch();

    // MintModule
    error CMTAT_MintModule_EmptyAccounts();
    error CMTAT_MintModule_AccountsValueslengthMismatch();

    // ERC20BaseModule
    error CMTAT_ERC20BaseModule_EmptyTos();
    error CMTAT_ERC20BaseModule_TosValueslengthMismatch();
    
    // DebtModule
    error CMTAT_DebtModule_SameValue();

    // BaseModule
    error CMTAT_BaseModule_SameValue();

    // ValidationModule
    error CMTAT_ValidationModule_SameValue();
}
    