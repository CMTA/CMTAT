// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
* @title IERC8343 - Contract Deactivation
* @notice Interface for permanently deactivating a token contract and exposing its
* deactivation status on-chain. Follows the proposed ERC-8343 (draft, not yet merged).
*
* @dev The issuer must be able to "deactivate" the smart contract, to prevent execution of
* transactions on the distributed ledger.
* Contrary to the "burn" function, the "deactivateContract" function
* affects all tokens in issuance, and not only some of them.
*
* a) This function is necessary to allow the issuer to carry out certain corporate actions
* (e.g. share splits, reverse splits or mergers), which
* require that all existing tokens are either canceled or immobilized and decoupled from the shares
* (i.e. the tokens no longer represent shares).
*
* b) The "deactivateContract" function can also be used if the issuer decides that it no longer wishes
* to have its shares issued in the form of ledger-based securities.
*
* The "deactivateContract" function does not delete the smart contract's
* storage and code, i.e. tokens are not burned by the function, however it permanently and
* irreversibly deactivates the smart contract (unless a proxy is used).
*
* @dev The ERC-8343 interface identifier is `0xe9cd80b0`, the exclusive-or of the selectors of
* `deactivateContract()` and `deactivated()`. This interface deliberately does NOT inherit
* `IERC165`, so that `type(IERC8343).interfaceId` equals `0xe9cd80b0`; adding `is IERC165` would
* fold `supportsInterface`'s selector into the id and change it. ERC-165 support is advertised
* separately by the implementing contract.
*/
interface IERC8343 {
     /**
     * @notice Emitted when the contract is permanently deactivated.
     * @param account The address that performed the deactivation.
     */
    event Deactivated(address indexed account);

    /**
     * @notice Error raised when deactivation is attempted after deactivation is already final.
     */
    error AlreadyDeactivated();

     /*
     * @notice Permanently deactivates the contract.
     * @dev
     * This action is irreversible — once executed, the contract cannot be reactivated.
     * Requirements:
     * - The contract MUST be paused before deactivation is allowed.
     * Emits a {Deactivated} event.
     * WARNING: Use with caution. This action permanently disables core contract functionality.
     */
    function deactivateContract() external;

     /**
     * @notice Returns whether the contract has been permanently deactivated.
     * @return isDeactivated A boolean indicating the deactivation status.
     * @dev Returns `true` if `deactivateContract()` has been successfully called.
     */
    function deactivated() external view returns (bool isDeactivated);
}
