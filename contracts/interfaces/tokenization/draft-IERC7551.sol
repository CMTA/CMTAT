//SPDX-License-Identifier: MPL-2.0
import {IERC3643ComplianceRead} from "./IERC3643Partial.sol";
import {IERC5679Mint, IERC5679Burn} from "../technical/IERC5679.sol";
pragma solidity ^0.8.20;


/**
 * @title IERC7551Mint
 * @dev Interface for token minting operations. 
 */
interface IERC7551Mint is IERC5679Mint {
     /**
     * @notice Emitted when new tokens are minted and assigned to an account.
     * @param minter The address that initiated the mint operation.
     * @param account The address receiving the newly minted tokens.
     * @param value The amount of tokens created.
     * @param data Optional metadata associated with the mint (e.g., reason, reference ID).
     */
    event Mint(address indexed minter, address indexed account, uint256 value, bytes data);
}
/**
* @title interface for burn operation
*/
interface IERC7551Burn is IERC5679Burn {
     /**
     * @notice Emitted when tokens are burned from an account.
     * @param burner The address that initiated the burn.
     * @param account The address from which tokens were burned.
     * @param value The amount of tokens burned.
     * @param data Additional data related to the burn.
     */
    event Burn(address indexed burner, address indexed account, uint256 value, bytes data);
}

interface IERC7551Pause {
    /**
     * @notice Returns true if token transfers are currently paused.
     * @return True if paused, false otherwise.
     * @dev  
     * If this function returns true, it MUST NOT be possible to transfer tokens to other accounts 
     * and the function canTransfer() MUST return false.
     */
    function paused() external view returns (bool);
    /**
     * @notice Pauses token transfers.
     * @dev Reverts if already paused.
          * Emits a `Paused` event
     */
    function pause() external;
    /**
     * @notice Unpauses token transfers.
     * @dev Reverts if token is not in pause state.
     * emits an `Unpaused` event
     */
    function unpause() external;
}
interface IERC7551ERC20EnforcementEvent {
    /**
     * @notice Emitted when a forced transfer or burn occurs.
     * @param enforcer The address that initiated the enforcement.
     * @param account The address affected by the enforcement.
     * @param amount The number of tokens involved.
     * @param data Additional data related to the enforcement.
     */
    event Enforcement (address indexed enforcer, address indexed account, uint256 amount, bytes data);
}

interface IERC7551ERC20EnforcementTokenFrozenEvent {
    /**
     * @notice Emitted when a specific amount of tokens are frozen on an address.
     * @param account The address whose tokens are frozen.
     * @param value The number of tokens frozen.
     * @param data Additional data related to the freezing action.
     *  @dev
     *  Same name as ERC-3643 but with a supplementary data parameter
     *  The event is emitted by freezePartialTokens and batchFreezePartialTokens functions
     */
    event TokensFrozen(address indexed account, uint256 value, bytes data);

    /**
     * @notice Emitted when a specific amount of tokens are unfrozen on an address.
     * @param account The address whose tokens are unfrozen.
     * @param value The number of tokens unfrozen.
     * @param data Additional data related to the unfreezing action.
     * @dev 
     * Same name as ERC-3643 but with a supplementary data parameter
     * The event is emitted by `unfreezePartialTokens`, `batchUnfreezePartialTokens`and potentially `forcedTransfer` functions
     */
    event TokensUnfrozen(address indexed account, uint256 value, bytes data);
}

interface IERC7551ERC20Enforcement {
     /* ============ View Functions ============ */
    /**
     * @notice Returns the active (unfrozen) token balance of a given account.
     * @param account The address to query.
     * @return activeBalance_ The amount of tokens that can be transferred using standard ERC-20 functions.
     */
    function getActiveBalanceOf(address account) external view returns (uint256 activeBalance_);


    /**
     * @notice Returns the frozen token balance of a given account.
     * @dev Frozen tokens cannot be transferred using standard ERC-20 functions.
     * Implementations MAY support transferring frozen tokens using other mechanisms like `forcedTransfer`.
     * If the active balance is insufficient to cover a transfer, `canTransfer` and `canTransferFrom` MUST return false.
     * @param account The address to query.
     * @return frozenBalance_ The amount of tokens that are frozen and non-transferable via ERC-20 `transfer` and `transferFrom`.
     */
    function getFrozenTokens(address account) external view returns (uint256 frozenBalance_);
    
     /* ============ State Functions ============ */
    /**
     * @notice Freezes a specified amount of tokens for a given account.
     * @dev Emits a `TokensFrozen` event.
     * @param account The address whose tokens will be frozen.
     * @param amount The number of tokens to freeze.
     * @param data Arbitrary additional data for logging or business logic.
     */
    function freezePartialTokens(address account, uint256 amount, bytes memory data) external;
    

    /**
     * @notice Unfreezes a specified amount of tokens for a given account.
     * @dev Emits a `TokensUnfrozen` event.
     * @param account The address whose tokens will be unfrozen.
     * @param amount The number of tokens to unfreeze.
     * @param data Arbitrary additional data for logging or business logic.
     */
    function unfreezePartialTokens(address account, uint256 amount, bytes memory data) external;
    /**
     * @notice Executes a forced transfer of tokens from one account to another.
     * @dev Transfers `value` tokens from `account` to `to` without requiring the account’s consent.
     * If the `account` does not have enough active (unfrozen) tokens, frozen tokens may be automatically unfrozen to fulfill the transfer.
     * Emits a `Transfer` event. Emits a `TokensUnfrozen` event if frozen tokens are used.
     * @param account The address to debit tokens from.
     * @param to The address to credit tokens to.
     * @param value The amount of tokens to transfer.
     * @param data Optional additional metadata to accompany the transfer.
     * @return success_ Returns true if the transfer was successful.
     */
    function forcedTransfer(address account, address to, uint256 value, bytes calldata data) external returns (bool success_);
}

interface IERC7551Compliance is IERC3643ComplianceRead {
     /**
     * @notice Checks if `spender` can transfer `value` tokens from `from` to `to` under compliance rules.
     * @dev Does not check balances or access rights (Access Control).
     * @param spender The address performing the transfer.
     * @param from The source address.
     * @param to The destination address.
     * @param value The number of tokens to transfer.
     * @return isCompliant True if the transfer complies with policy.
     */
    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    )  external view returns (bool);
}

interface IERC7551Document {
    /**
     * @notice Returns the hash of the "Terms" document.
     * @return hash_ The `bytes32` hash of the terms document.
     */
    function termsHash() external view returns (bytes32 hash_);

    /**
     * @notice Sets the terms hash and URI.
     * @param _hash The new hash of the document.
     * @param _uri The corresponding URI.
     */
    function setTerms(bytes32 _hash, string calldata _uri) external;

    /**
    * @notice Returns the metadata string (e.g. URL).
    * @return metadata_ The metadata string.
    */
    function metaData() external view returns (string memory metadata_);

    /**
    * @notice Sets a new metadata string (e.g. URL).
    * @param metaData_ The new metadata value.
    */
    function setMetaData(string calldata metaData_) external;
}