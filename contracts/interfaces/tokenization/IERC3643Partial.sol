//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @dev  Common interface between CMTAT and ERC3643
* Note that arguments name can change compare to ERC3643 because we use the same semantics as OpenZeppelin v.5.2.0 (e.g amount -> value)
*/
interface IERC3643Pause {
    /**
     * @notice Returns true if the contract is paused, and false otherwise.
     */
    function paused() external view returns (bool);
    /**
     *  @notice pauses the token contract, 
     *  @dev When contract is paused token holders cannot transfer tokens anymore
     *  
     */
    function pause() external;

    /**
     *  @notice unpauses the token contract, 
     *  @dev When contract is unpaused token holders can transfer tokens
     *  
     *  
     */
    function unpause() external;
} 
interface IERC3643ERC20Base {
    /**
     *  @notice sets the token name
     *  @param name the name of token to set
     */
    function setName(string calldata name) external;
    /**
     *  @notice sets the token symbol
     *  @param symbol the token symbol to set
     */
    function setSymbol(string calldata symbol) external;
}

interface IERC3643BatchTransfer {
    /**
     *  @notice batch version of transfer
     *  @param tos The addresses of the receivers tos can not be empty
     *  @param values The number of tokens to transfer to the corresponding receiver
     *  @dev function allowing the minter to transfers in batch
     *  If IERC3643Enforcement is implemented:
     *      Require that the msg.sender and `to` addresses are not frozen.
     *  If IERC364320Enforcement is implemented:
     *      Require that the total value should not exceed available balance.
     *  
     *  Emits tos .length `Transfer` events
     *  Warning: 
     *  Contrary to ERC-3643 specification, return bool to keep the same behaviour as ERC-20 transfer
     */
    function batchTransfer(address[] calldata tos,uint256[] calldata values) external returns (bool);
}

interface IERC3643Base {
    /**
     * @dev Returns the current version of the token.
     */
    function version() external view returns (string memory);
}

interface IERC3643EnforcementEvent {
    /**
     *  this event is emitted when an address is frozen or unfrozen
     *  the event is emitted by setAddressFrozen and batchSetAddressFrozen functions
     *  `account` is the address that is concerned by the freezing status
     *  `isFrozen` is the freezing status of the address
     *  if `isFrozen` equals `true` the address is frozen after emission of the event
     *  if `isFrozen` equals `false` the address is unfrozen after emission of the event
     *  `enforcer` is the address of the enforcer  who called the function to freeze the address
     *  Warning: contrary to ERC-3643 specification, add a supplementary field data to further document the action.
     */
    event AddressFrozen(address indexed account, bool indexed isFrozen, address indexed enforcer, bytes data);
}
interface IERC3643Enforcement {
    /**
     * @notice Returns true if the account is frozen, and false otherwise.
     */
    function isFrozen(address account) external view returns (bool);
    /**
     *  @notice sets an address frozen status for this token.
     *  @param account The address for which to update frozen status
     *  @param freeze Frozen status of the address
     *  @dev
     *  Emits an `AddressFrozen` event
     */
    function setAddressFrozen(address account, bool freeze) external;
    /**
    * @notice Batch version of {setAddressFrozen}
    */
    function batchSetAddressFrozen(address[] calldata accounts, bool[] calldata freeze) external;
}

/**
* 
* @dev For events, see {IERC7551ERC20Enforcement}
*/
interface IERC3643ERC20Enforcement {


    /**
     *  @notice Returns the amount of tokens that are partially frozen on a wallet
     *  @dev 
     *  The amount of frozen tokens is always <= to the total balance of the wallet
     *  @param `account` the address of the wallet on which getFrozenTokens is called
     */
    function getFrozenTokens(address account) external view returns (uint256);

    /**
     *  @notice freezes token amount specified for given address.
     *  @param account The address for which to update frozen tokens
     *  @param value Amount of Tokens to be frozen
     *  @dev emits a `TokensFrozen` event
     */
    function freezePartialTokens(address account, uint256 value) external;
    /**
     *  @notice unfreezes token amount specified for given address
     *  @param account The address for which to update frozen tokens
     *  @param value Amount of Tokens to be unfrozen
     *  @dev Emits a `TokensUnfrozen` event
     */
    function unfreezePartialTokens(address account, uint256 value) external;
    /**
     *  
     *  @notice Triggers a forced transfer.
     *  
     *  @param from The address of the token holder
     *  @param to The address of the receiver
     *  @param value amount of tokens to transfer
     *  @return `true` if successful and revert if unsuccessful
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
     *  emits a `Transfer` event
     */
    function forcedTransfer(address from, address to, uint256 value) external returns (bool);

}
interface IERC3643Mint{
    /**
     * @notice  Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)
     * @param account token receiver
     * @param value amount of tokens to mint
     */
    function mint(address account, uint256 value) external;
    /**
     *  @notice batch version of {mint}
     *  @dev function allowing to mint tokens in batch
     *  IMPORTANT : This transaction could exceed gas limit if `tos.length` is too heigh,
     *  Use with care or you could lose TX fees with an "OUT OF GAS" transaction
     *  @param accounts The addresses of the receivers
     *  @param values The number of tokens to mint to the corresponding receiver
     *  emits accounts.length `Transfer` events
     */
    function batchMint( address[] calldata accounts,uint256[] calldata values) external;
}
interface IERC3643Burn{
    /**
     * @notice Burns tokens from a given address by transferring it to address(0)
     * @param account The address to burn tokens from.
     * @param value The number of tokens to be burned.
     * @dev burn tokens on an address, decreases the total supply.
     *  If IERC364320Enforcement is implemented:
     *      In case the `account` address has not enough free tokens (unfrozen tokens)
     *      but has a total balance higher or equal to the `value` amount
     *      the amount of frozen tokens is reduced in order to have enough free tokens
     *      to proceed the burn, in such a case, the remaining balance on the `account`
     *      is 100% composed of frozen tokens post-transaction.
     *      emits a `TokensUnfrozen` event if `_amount` is higher than the free balance of `account`
     * Emits a `Transfer` event
     */
    function burn(address account,uint256 value) external;
    /**
     *  @dev batch version of {burn}
     *  IMPORTANT : This transaction could exceed gas limit if `tos.length` is too heigh,
     *  Use with care or you could lose TX fees with an "OUT OF GAS" transaction
     *  @param accounts The addresses of the wallets concerned by the burn
     *  @param values Amount of tokens to burn from the corresponding addresses
     *  emits accounts.length `Transfer` events
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

interface IERC3743IComplianceContract {
    /**
     *  @dev function called whenever tokens are transferred
     *  from one wallet to another
     *  this function can be used to update state variables of the compliance contract
     *  This function can be called ONLY by the token contract bound to the compliance
     *  @param from The address of the sender
     *  @param to The address of the receiver
     *  @param value value of tokens involved in the transfer
     */
    function transferred(address from, address to, uint256 value) external view;
}

