// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @notice Enforcement Interface for ERC-20 based implementations common with ERC-3643 interface.
* 
*/
interface IERC7943ERC20Enforcement {
    /* ============ View Functions ============ */
    /** 
    * @notice Checks the frozen status/amount.
    * @param account The address of the account.
    * @dev 
    * ERC-7943 specification: 
    *   It could return an amount higher than the account's balance.
    * ERC-3643 compatibility
    *   The frozen amount is always less than or equal to the total balance of the account.
    * @return amount The amount of tokens currently frozen for `account`.
    */
    function getFrozenTokens(address account) external view returns (uint256 amount);
    
    /* ============ State Functions ============ */
    /** 
    * @notice Takes tokens from one address and transfers them to another.
    * @dev 
    * Requires specific authorization. Used for regulatory compliance or recovery scenarios.
    * It MAY bypass the canTransfer checks. 
    *   If this happens, it MUST unfreeze the assets first 
    *   and emit a Frozen event before the underlying base token transfer event reflecting the change. 
    *   Having the unfrozen amount changed before the actual transfer is critical 
    *   for tokens that might be susceptible to reentrancy attacks doing external checks on recipients 
    *   as it is the case for ERC-721 and ERC-1155 tokens.
    * Compatibility with ERC-3643 (not part of IERC7943 interface):
    *      If IERC364320Enforcement is implemented:
    *      Require that the total value should not exceed available balance.
    *      In case the `from` address has not enough free tokens (unfrozen tokens)
    *      but has a total balance higher or equal to the `amount`
    *      the amount of frozen tokens is reduced in order to have enough free tokens
    *      to proceed the transfer, in such a case, the remaining balance on the `from`
    *      account is 100% composed of frozen tokens post-transfer.
    *      Emits a `TokensUnfrozen` event if `value` is higher than the free balance of `from`
    *      Emits a `Transfer` event
    * @param from The address from which `amount` is taken.
    * @param to The address that receives `amount`.
    * @param amount The amount to force transfer.
    * @return result True if the transfer executed correctly, false otherwise.
    */
    function forcedTransfer(address from, address to, uint256 amount) external returns(bool result);
}

interface IERC7943ERC20EnforcementSpecific {
    /** 
    * @notice Changes the frozen status of `amount` tokens belonging to `account`.
    * This overwrites the current value, similar to an `approve` function.
    * @dev Requires specific authorization. Frozen tokens cannot be transferred by the account.
    * @param account The address of the account whose tokens are to be frozen.
    * @param amount The amount of tokens to freeze. It can be greater than account balance.
    * @return result True if the freezing executed correctly, false otherwise.
    */
    function setFrozenTokens(address account, uint256 amount) external returns(bool result);
}
interface IERC7943FungibleEnforcementEvent{
    /** 
    * @notice Emitted when `setFrozenTokens` is called, changing the frozen `amount` of tokens for `account`.
    * @param account The address of the account whose tokens are being frozen.
    * @param amount The amount of tokens frozen after the change.
    */
    event Frozen(address indexed account, uint256 amount);

    /** @notice Emitted when tokens are taken from one address and transferred to another.
    * @param from The address from which tokens were taken.
    * @param to The address to which seized tokens were transferred.
    * @param amount The amount seized.
    */
    event ForcedTransfer(address indexed from, address indexed to, uint256 amount);
}

/**
* @notice Transfer Error Interface for ERC-20, ERC-721 and ERC-1155 based implementations.
* 
*/
interface IERC7943TransactError{
    /**
    * @notice Error reverted when an account is not allowed to transact. 
    * @param account The address of the account which is not allowed for transfers.
    */ 
    error ERC7943CannotTransact(address account);
}

/**
* @notice Transfer Error Interface for ERC-20 based implementations.
* 
*/
interface IERC7943FungibleTransferError {
    /** 
    * @notice Error reverted when a transfer is not allowed according to internal rules. 
    * @param from The address from which tokens are being sent.
    * @param to The address to which tokens are being sent.
    * @param amount The amount sent.
    */
    error ERC7943CannotTransfer(address from, address to, uint256 amount);
}
