//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/**
 * @title ERC20Mint module.
 * @dev 
 *
 * Contains all mint functions, inherits from ERC-20
 */
abstract contract ERC20MintModuleInternal is ERC20Upgradeable {
    /// @notice Reverts when the `accounts` array provided for a mint batch operation is empty.
    error CMTAT_MintModule_EmptyAccounts();
    /// @notice Reverts when the `accounts` and `values` arrays provided for batch minting have mismatched lengths.
    /// @dev Both arrays must have the same number of elements.
    error CMTAT_MintModule_AccountsValueslengthMismatch();
    /// @notice Reverts when the `tos` array provided for a batch transfer is empty.
    error CMTAT_MintModule_EmptyTos();
    /// @notice Reverts when the `tos` and `values` arrays provided for batch transfer have mismatched lengths.
    /// @dev Both arrays must contain the same number of elements.
    error CMTAT_MintModule_TosValueslengthMismatch();


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _batchMint(
        address[] calldata accounts,
        uint256[] calldata values
    ) internal virtual {
        require(accounts.length > 0, CMTAT_MintModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), CMTAT_MintModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
            _mintOverride(accounts[i], values[i]);
        }
    }

    function _batchTransfer(
        address[] calldata tos,
        uint256[] calldata values
    ) internal virtual returns (bool success_) {
        require(tos.length > 0, CMTAT_MintModule_EmptyTos());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(tos.length == values.length), CMTAT_MintModule_TosValueslengthMismatch());
        // No need of unchecked block since Soliditiy 0.8.22
        for (uint256 i = 0; i < tos.length; ++i) {
            // We call directly the internal OpenZeppelin function _transfer
            // The reason is that the public function adds only the owner address recovery
            ERC20Upgradeable._transfer(_msgSender(), tos[i], values[i]);
        }
        // not really useful
        // Here only to keep the same behaviour as transfer
        return true;
    }

    /**
    *  @dev Can be override to emit event
    */
    function _mintOverride(address account, uint256 value) internal virtual {
        ERC20Upgradeable._mint(account, value);
    }
}
