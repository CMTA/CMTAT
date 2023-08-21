//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

library Errors {
    // CMTAT
    error CMTAT_InvalidTransfer(address from, address to, uint256 amount);
    
    // SnapshotModule
    error CMTAT_SnapshotModule_SnapshotScheduledInThePast(uint256 time, uint256 timestamp);
    error CMTAT_SnapshotModule_SnapshotTimestampBeforeLastSnapshot(uint256 time, uint256 lastSnapshotTimestamp);
    error CMTAT_SnapshotModule_SnapshotTimestampAfterNextSnapshot(uint256 time, uint256 nextSnapshotTimestamp);
    error CMTAT_SnapshotModule_SnapshotTimestampBeforePreviousSnapshot(uint256 time, uint256 previousSnapshotTimestamp);
    error CMTAT_SnapshotModule_SnapshotAlreadyExists();
    error CMTAT_SnapshotModule_SnapshotAlreadyDone();
    error CMTAT_SnapshotModule_SnapshotNotScheduled();
    error CMTAT_SnapshotModule_SnapshotNotFound();
    error CMTAT_SnapshotModule_SnapshotNeverScheduled();
    
    // Generic
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

    // AuthorizationModule
    error CMTAT_AuthorizationModule_AddressZeroNotAllowed();
}
    