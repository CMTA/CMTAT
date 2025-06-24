//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModuleInternal is ERC20Upgradeable {
    error CMTAT_BurnModule_EmptyAccounts();
    error CMTAT_BurnModule_AccountsValueslengthMismatch();

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev internal function to burn in batch
    */
    function _batchBurn(
        address[] calldata accounts,
        uint256[] calldata values
    ) internal virtual {
        require(accounts.length != 0, CMTAT_BurnModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), CMTAT_BurnModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
             _burnOverride(accounts[i], values[i]);
        }
    }

    /**
    * @dev Internal function to burn
    * Can be override to perform supplémentary check on burn action
    */
    function _burnOverride(
        address account,
        uint256 value
    ) internal virtual {
        ERC20Upgradeable._burn(account, value);
    }


}
