/// @notice Interface for ERC-20 based implementations.
interface IERC7943ERC20Enforcement{

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

interface IERC7943FungibleTransactErrors{
    /// @notice Error reverted when an account is not allowed to transact. 
    /// @param account The address of the account which is not allowed for transfers.
    error ERC7943CannotTransact(address account);


}
interface IERC7943FungibleTransferErrors {
    /// @notice Error reverted when a transfer is not allowed according to internal rules. 
    /// @param from The address from which tokens are being sent.
    /// @param to The address to which tokens are being sent.
    /// @param amount The amount sent.
    error ERC7943CannotTransfer(address from, address to, uint256 amount);
}
