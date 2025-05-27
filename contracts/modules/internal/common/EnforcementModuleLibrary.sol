//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
 * @dev Enforcement module.
 *
 * Allows the issuer to freeze transfers from a given address
 */
library EnforcementModuleLibrary
{
    error CMTAT_EnforcementModuleInternal_EmptyAccounts();
    error CMTAT_EnforcementModuleInternal_AccountsValueslengthMismatch();
    function _checkInput(address[] calldata accounts, bool[] calldata status) internal pure{
        require(accounts.length > 0, CMTAT_EnforcementModuleInternal_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == status.length), CMTAT_EnforcementModuleInternal_AccountsValueslengthMismatch());
    }
}
