//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev CMTAT custom errors
*/
library Errors {
    // CMTAT
    error CMTAT_InvalidTransfer(address from, address to, uint256 amount);

    // SnapshotModule
    error CMTAT_SnapshotModule_SameValue();
    
    // ERC20BaseModule
    error CMTAT_ERC20BaseModule_WrongAllowance(
        address spender,
        uint256 currentAllowance,
        uint256 allowanceProvided
    );

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

    // ValidationModule
    error CMTAT_ValidationModule_SameValue();

    // AuthorizationModule
    error CMTAT_AuthorizationModule_AddressZeroNotAllowed();
    error CMTAT_AuthorizationModule_InvalidAuthorization();
    error CMTAT_AuthorizationModule_AuthorizationEngineAlreadySet(); 

    error CMTAT_TransferEngineModule_TransferEngineAlreadySet();

    // DocumentModule
    error CMTAT_DocumentModule_SameValue();

    // PauseModule
    error CMTAT_PauseModule_ContractIsDeactivated();
}
