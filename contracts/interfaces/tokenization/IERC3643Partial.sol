// SPDX-License-Identifier: MPL-2.0

/**
* Note:
* Parameter names may differ slightly from the original ERC3643 spec 
* to align with OpenZeppelin v5.3.0 naming conventions 
* (e.g., `amount` → `value`).
*/ 

pragma solidity ^0.8.20;

/**
 * @title IERC3643Pause
 * @dev Interface for pausing and unpausing token transfers.
 * Common interface shared between CMTAT and ERC3643 implementations.
 *
 */
interface IERC3643Pause {
    /**
     * @notice Indicates whether the contract is currently paused.
     * @dev When paused, token transfers are disabled.
     * @return True if the contract is paused, false otherwise.
     */
    function paused() external view returns (bool);
    /**
     * @notice Pauses all token transfers.
     * @dev Once paused, calls to transfer-related functions will revert.
     * Can only be called by an account with the appropriate permission.
     *
     * Emits a {Paused} event.
     */
    function pause() external;

    /**
     * @notice Unpauses token transfers.
     * @dev Restores normal token transfer behavior after a pause.
     * Can only be called by an account with the appropriate permission.
     *
     * Emits an {Unpaused} event.
     */
    function unpause() external;
} 
/**
 * @title ERC-3643 Base Interface for ERC-20 Token Metadata
 * @dev Provides functions to update token name and symbol.
 */
interface IERC3643ERC20Base {
    /**
     * @notice Updates the name of the token.
     * @dev Can be used to rename the token post-deployment.
     * @param name The new name to assign to the token.
     */
    function setName(string calldata name) external;

    /**
     * @notice Updates the symbol of the token.
     * @dev Can be used to change the token's symbol (e.g. for branding or reissuance).
     * @param symbol The new symbol to assign to the token.
     */
    function setSymbol(string calldata symbol) external;
}

/**
 * @title IERC3643BatchTransfer
 * @notice Interface for batch token transfers under the ERC-3643 standard.
 */
interface IERC3643BatchTransfer {
     /**
     * @notice Transfers tokens to multiple recipient addresses in a single transaction.
     * @dev 
     * Batch version of `transfer`
     * - Each recipient receives the number of tokens specified in the `values` array.
     * Requirement:
     * - The `tos` array must not be empty.
     * - `tos.length` must equal `values.length`.
     * - `tos`cannot contain a zero address
     * - the caller must have a balance cooresponding to the total values
     * Events:
     * - Emits one `Transfer` event per recipient (i.e., `tos.length` total).
     * 
     * Enforcement-specific behavior:
     * - If `IERC3643Enforcement` is implemented: 
     *   - The sender (`msg.sender`) and each recipient in `tos` MUST NOT be frozen.
     * - If `IERC3643ERC20Enforcement` is implemented:
     *   - The total amount transferred MUST NOT exceed the sender's available (unfrozen) balance.
     *
     * Note: This implementation differs from the base ERC-3643 specification by returning a `bool`
     *       value for compatibility with the ERC-20 `transfer` function semantics.
     *
     * @param tos The list of recipient addresses.
     * @param values The list of token amounts corresponding to each recipient.
     * @return success_ A boolean indicating whether the batch transfer was successful.
     */
    function batchTransfer(address[] calldata tos,uint256[] calldata values) external returns (bool success_);
}

/**
 * @title IERC3643Base
 * @notice Interface to retrieve version
 */
interface IERC3643Version {
     /**
     * @notice Returns the current version of the token contract.
     * @dev This value is useful to know which smart contract version has been used
     * @return version_ A string representing the version of the token implementation (e.g., "1.0.0").
     */
    function version() external view returns (string memory version_);
}

/**
 * @title IERC3643EnforcementEvent
 * @notice Interface defining the event for account freezing and unfreezing.
 */
interface IERC3643EnforcementEvent {
    /**
     * @notice Emitted when an account's frozen status is changed.
     * @dev 
     * - `account` is the address whose status changed.
     * - `isFrozen` reflects the new status after the function execution:
     *    - `true`: account is frozen.
     *    - `false`: account is unfrozen.
     * - `enforcer` is the address that executed the freezing/unfreezing.
     * - `data` provides optional contextual information for auditing or documentation purposes.
     * The event is emitted by `setAddressFrozen` and `batchSetAddressFrozen` functions
     * Note: This event extends the ERC-3643 specification by including the `data` field.
     * 
     * @param account The address that was frozen or unfrozen.
     * @param isFrozen The resulting freeze status of the account.
     * @param enforcer The address that initiated the change.
     * @param data Additional data related to the freezing action.
     */
    event AddressFrozen(address indexed account, bool indexed isFrozen, address indexed enforcer, bytes data);
}

/**
 * @title IERC3643Enforcement
 * @notice Interface for account-level freezing logic.
 * @dev Provides methods to check and update whether an address is frozen.
 */
interface IERC3643Enforcement {
    /**
     * @notice Checks whether a given account is currently frozen.
     * @param account The address to query.
     * @return isFrozen_ A boolean indicating if the account is frozen (`true`) or not (`false`).
     */
    function isFrozen(address account) external view returns (bool isFrozen_);
    /**
     * @notice Sets the frozen status of a specific address.
     * @dev Emits an `AddressFrozen` event.
     * @param account The address whose frozen status is being updated.
     * @param freeze The new frozen status (`true` to freeze, `false` to unfreeze).
     */
    function setAddressFrozen(address account, bool freeze) external;
    /**
     * @notice Batch version of {setAddressFrozen}, allowing multiple addresses to be updated in one call.
     * @param accounts An array of addresses to update.
     * @param freeze An array of corresponding frozen statuses for each address.
     * Requirements:
     * - `accounts.length` must be equal to `freeze.length`.
     */
    function batchSetAddressFrozen(address[] calldata accounts, bool[] calldata freeze) external;
}

/**
 * @title IERC3643ERC20Enforcement
 * @notice Interface for enforcing partial token freezes and forced transfers, typically used in compliance-sensitive ERC-1400 scenarios.
 * @dev For event definitions, see {IERC7551ERC20Enforcement}.
 */
interface IERC3643ERC20Enforcement {
    /* ============ View Functions ============ */
    /**
     * @notice Returns the number of tokens that are currently frozen (i.e., non-transferable) for a given account.
     * @dev The frozen amount is always less than or equal to the total balance of the account.
     * @param account The address of the wallet being queried.
     * @return frozenBalance_ The amount of frozen tokens held by the account.
     */
    function getFrozenTokens(address account) external view returns (uint256 frozenBalance_);


    /* ============ State Functions ============ */

    /**
     * @notice Freezes a specific amount of tokens for a given account.
     * @dev Emits a `TokensFrozen` event. Prevents the frozen amount from being transferred.
     * @param account The wallet address whose tokens are to be frozen.
     * @param value The amount of tokens to freeze.
     */
    function freezePartialTokens(address account, uint256 value) external;
 
     /**
     *  @notice unfreezes token amount specified for given address
     *  @dev Emits a TokensUnfrozen event
     *  @param account The address for which to update frozen tokens
     *  @param value Amount of Tokens to be unfrozen
     */
    function unfreezePartialTokens(address account, uint256 value) external;
    /**
     *  
     *  @notice Triggers a forced transfer.
     *  @dev 
*    *  Force a transfer of tokens between 2 token holders
     *  If IERC364320Enforcement is implemented:
     *      Require that the total value should not exceed available balance.
     *      In case the `from` address has not enough free tokens (unfrozen tokens)
     *      but has a total balance higher or equal to the `amount`
     *      the amount of frozen tokens is reduced in order to have enough free tokens
     *      to proceed the transfer, in such a case, the remaining balance on the `from`
     *      account is 100% composed of frozen tokens post-transfer.
     *      emits a `TokensUnfrozen` event if `value` is higher than the free balance of `from`
     *  Emits a `Transfer` event
     *  @param from The address of the token holder
     *  @param to The address of the receiver
     *  @param value amount of tokens to transfer
     *  @return success_ `true` if successful and revert if unsuccessful

     */
    function forcedTransfer(address from, address to, uint256 value) external returns (bool success_);

}
/**
* @title IERC3643Mint — Token Minting Interface
* @dev Interface for mintint ERC-20 compatible tokens under the ERC-3643 standard.
* Implements both single and batch mint functionalities, with support for frozen address logic if enforced.
*/
interface IERC3643Mint{
    /**
     * @notice Creates (`mints`) a specified `value` of tokens and assigns them to the `account`.
     * @dev Tokens are minted by transferring them from the zero address (`address(0)`).
     * Emits a {Mint} event and a {Transfer} event with `from` set to `address(0)`.
     * Requirement:
     * Account must not be the zero address.
     * @param account The address that will receive the newly minted tokens. 
     * @param value The amount of tokens to mint to `account`.
     */
    function mint(address account, uint256 value) external;
    /**
     * @notice Batch version of {mint}, allowing multiple mint operations in a single transaction.
     * @dev
     * For each mint action:
     *   - Emits a {Mint} event.
     *   - Emits a {Transfer} event with `from` set to the zero address.
     * - Requires that `accounts` and `values` arrays have the same length.
     * - None of the addresses in `accounts` can be the zero address.
     * - Be cautious with large arrays as the transaction may run out of gas.
     * @param accounts The list of recipient addresses for the minted tokens.
     * @param values The respective amounts of tokens to mint for each recipient.
     */
    function batchMint( address[] calldata accounts,uint256[] calldata values) external;
}

/**
* @title IERC3643Burn — Token Burning Interface
* @dev Interface for burning ERC-20 compatible tokens under the ERC-3643 standard.
* Implements both single and batch burn functionalities, with support for frozen token logic if enforced.
*/
interface IERC3643Burn{
     /**
     * @notice Burns a specified amount of tokens from a given account by transferring them to `address(0)`.
     * @dev 
     * - Decreases the total token supply by the specified `value`.
     * - Emits a `Transfer` event to indicate the burn (with `to` set to `address(0)`).
     * - If `IERC364320Enforcement` is implemented:
     *   - If the account has insufficient free (unfrozen) tokens but a sufficient total balance, 
     *     frozen tokens are reduced to complete the burn.
     *   - The remaining balance on the account will consist entirely of frozen tokens after the burn.
     *   - Emits a `TokensUnfrozen` event if frozen tokens are unfrozen to allow the burn.
     * 
     * @param account The address from which tokens will be burned.
     * @param value The amount of tokens to burn.
     */
    function burn(address account,uint256 value) external;
    /**
     * @notice Performs a batch burn operation, removing tokens from multiple accounts in a single transaction.
     * @dev 
     * - Batch version of {burn}
     * - Executes the burn operation for each account in the `accounts` array, using corresponding amounts in the `values` array.
     * - Emits a `Transfer` event for each burn (with `to` set to `address(0)`).
     * - This operation is gas-intensive and may fail if the number of accounts (`accounts.length`) is too large, causing an "out of gas" error.
     * - Use with caution to avoid unnecessary transaction fees.
     * Requirement:
     *  - `accounts` and `values` must have the same length
     * @param accounts An array of addresses from which tokens will be burned.
     * @param values An array of token amounts to burn, corresponding to each address in `accounts`.
     */
    function batchBurn(address[] calldata accounts,uint256[] calldata values) external;
}

interface IERC3643ComplianceRead {
    /**
     * @notice Returns true if the transfer is valid, and false otherwise.
     * @dev Don't check the balance and the user's right (access control)
     */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) external view returns (bool isValid);
}

interface IERC3643IComplianceContract {
    /**
     *  @notice
     *  Function called whenever tokens are transferred
     *  from one wallet to another
     *  @dev 
     *  This function can be used to update state variables of the compliance contract
     *  This function can be called ONLY by the token contract bound to the compliance
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param value value of tokens involved in the transfer
     */
    function transferred(address from, address to, uint256 value) external;
}

