// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


/**
 * @title IMintERC20Event
 * @notice Standard interface for minting ERC-20 tokens.
 */
interface IMintBatchERC20Event {
    /**
     * @notice Emitted when tokens are minted in batch by a single minter.
     * @dev The `values` array specifies the amount of tokens minted to each corresponding address in `accounts`.
     * @param minter The address that initiated the batch mint operation.
     * @param accounts The list of addresses receiving minted tokens.
     * @param values The amounts of tokens minted to each corresponding account.
     */
    event BatchMint(
        address indexed minter,
        address[] accounts,
        uint256[] values
    );
}

/**
* @title IBurnMintERC20
* @notice standard interface for burn and mint atomically
 */
interface IBurnMintERC20 {
/**
* @notice burn and mint atomically
* @param from current token holder to burn tokens
* @param to receiver to send the new minted tokens
* @param amountToBurn number of tokens to burn
* @param amountToMint number of tokens to mint
*/
 function burnAndMint(address from, address to, uint256 amountToBurn, uint256 amountToMint, bytes calldata data) external;
}


interface IForcedBurnERC20 {
    /**
    * @notice Allows the issuer to forcibly burn tokens from a frozen address.
    * @param account The address from which tokens will be burned.
    * @param value The amount of tokens to burn.
    * @param data Additional data providing context for the burn (e.g., reason or reference).
    * @dev This function is typically restricted to authorized roles such as the issuer.
    */
  function forcedBurn(
        address account,
        uint256 value,
        bytes memory data
    ) external;
}

/** 
 * @notice Standard interface for token burning operations.
 */
interface IBurnBatchERC20 {
    /** ============ Events ============ */
    /**
     * @notice Emitted when tokens are burned in a batch operation.
     * @param burner The address that initiated the batch burn.
     * @param accounts The list of addresses from which tokens were burned.
     * @param values The respective amounts of tokens burned from each address.
     * @param data Additional data associated with the batch burn operation.
     */
    event BatchBurn(
        address indexed burner,
        address[] accounts,
        uint256[] values,
        bytes data
    );

    /**
     * @notice Burns tokens from multiple accounts in a single transaction.
     * @dev 
     *  Batch version of {burn}.
     * - For each burn, emits a `Transfer` event to the zero address.
     * - Emits a `burnBatch` event
     * - The `data` parameter applies uniformly to all burn operations in this batch.
     * - Requirements:
     *   - `accounts.length` must equal `values.length`.
     * @param accounts The list of addresses whose tokens will be burned.
     * @param values The respective number of tokens to burn from each account.
     * @param data Optional metadata or reason for the batch burn.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        bytes memory data
    ) external;
}

/**
 * @notice Standard interface for token burning operations with allowance.
 */
interface IBurnFromERC20 {
   /** ============ Events ============ */
    /**
     * @notice Emitted when a spender burns tokens on behalf of an account, reducing the spender's allowance.
     * @param burner The address that initiated the burn.
     * @param account The owner address from which tokens were burned.
     * @param spender The address authorized to burn tokens on behalf of the owner.
     * @param value The amount of tokens burned.
     */
    event BurnFrom(address indexed burner, address indexed account, address indexed spender, uint256 value);

    /** ============ Functions ============ */
   /**
     * @notice Burns a specified amount of tokens from a given account, deducting from the caller's allowance.
     * @param account The address whose tokens will be burned.
     * @param value The number of tokens to burn.
     * @dev The caller must have allowance for `account`'s tokens of at least `value`.
     * - Emits a `Spend` event
     * - Emits a `BurnFrom` event
     * This function decreases the total supply.
     * Can be used to authorize a bridge (e.g. CCIP) to burn token owned by the bridge
     * No data parameter reason to be compatible with Bridge, e.g. CCIP
     */
  function burnFrom(address account, uint256 value) external;

    /**
    * @notice Burns a specified amount of tokens from the caller's own balance.
    * @param value The number of tokens to burn.
    * @dev This function is restricted to authorized roles.
    */
    function burn(uint256 value) external;
}