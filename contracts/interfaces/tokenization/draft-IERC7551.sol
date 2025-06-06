//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


interface IERC7551Mint {
    /**
     * @notice Emitted when the specified  `value` amount of new tokens are created and
     * allocated to the specified `account`.
     */
    event Mint(address indexed minter, address indexed account, uint256 value, bytes data);
    /**
    * @notice Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)
    * @param account token receiver
    * @param value amount of tokens
    * @param data supplemtary field to further document the action.
    * @dev
    * This function increases the balance of to by amount without decreasing the amount of tokens from any other holder.  
    * It MUST emit a Transfer as well as an Mint event. 
    * If {IERC7551Pause} is implemented:
    *   Paused transfers MUST NOT prevent an issuance. 
    */
    function mint(address account, uint256 value, bytes calldata data) external;
}

interface IERC7551Burn {
    /**
    * @notice Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `data`
    */
    event Burn(address indexed burner, address indexed account, uint256 value, bytes data);
    /*
    * @notice  Burns tokens from a given address by transferring it to address(0)
    * @dev 
    * This function MUST reduce the balance of `account` by amount without increasing the amount of tokens of any other holder. 
    * It MUST emit a burn as well as a Transfer event. 
    * The Transfer event MUST contain 0x0 as the recipient account address. 
    * The function MUST throw if account’s balance is less than amount (including frozen tokens). 
    * The data parameter MAY be used to further document the action.
    * If {IERC7551Pause} is implemented:
    *   Paused transfers MUST NOT prevent a burn
    */
    function burn(address account, uint256 amount, bytes calldata data) external;
}

interface IERC7551Pause {
    /*
    * This function MUST return true if token transfers are paused and MUST return false otherwise. 
    * If this function returns true, it MUST NOT be possible to transfer tokens to other accounts 
    * and the function canTransfer() MUST return false.
    */
    function paused() external view returns (bool);
    /**
    * If _paused is provided as true transfers MUST become paused. 
    * If false is provided, transfers MUST be unpaused. 
    * The function MUST throw if true is provided although transfers are already paused as well as if false is provided while transfers are already unpaused. 
    */
    function pause() external;
    function unpause() external;
}
interface IERC7551ERC20EnforcementEvent {
    /**
    * @notice Emitted when a transfer or burn is forced.
    */
    event Enforcement (address indexed enforcer, address indexed account, uint256 amount, bytes data);
}

interface IERC7551ERC20Enforcement {
    /**
     *  @notice this event is emitted when a certain amount of tokens is frozen on an address
     *  @dev
     *  Same name as ERC-3643 but with a supplementary data parameter
     *  The event is emitted by freezePartialTokens and batchFreezePartialTokens functions
     *  `account` is the address that is concerned by the freezing status
     *  `value` is the amount of tokens that are frozen
     */
    event TokensFrozen(address indexed account, uint256 value, bytes data);

    /**
     *  @notice This event is emitted when a certain amount of tokens is unfrozen on an address
     *  @dev 
     *  Same name as ERC-3643 but with a supplementary data parameter
     *  The event is emitted by unfreezePartialTokens and batchUnfreezePartialTokens functions
     *  `account` is the address that is concerned by the freezing status
     *  `value` is the amount of tokens that are unfrozen
     */
    event TokensUnfrozen(address indexed account, uint256 value, bytes data);
    /**
    * @notice This function  returns the unfrozen balance of an account. 
    * @dev This balance can be used by the account for transfers to other account addresses.
    */
    function getActiveBalanceOf(address account) external view returns (uint256);
    /**
    * This function MUST return the frozen balance of an account. 
    * It MUST NOT be possible to transfer frozen tokens to other accounts. 
    * The implementation MAY provide other ways to transfer frozen tokens. 
    * If the sender’s unfrozen (“active”) balance is less than the amount to be transferred, 
    * the canTransfer() and canTransferFrom() MUST return false.
    */
    function getFrozenTokens(address account) external view returns (uint256);
    function freezePartialTokens(address account, uint256 amount, bytes memory data) external;
    function unfreezePartialTokens(address account, uint256 amount, bytes memory data) external;
    /*
    * @notice Triggers a forced transfer.
    * @dev This function transfer amount tokens to to without requiring the consent of from. 
    * The function throws if from’s balance is less than amount (including frozen tokens). 
    * If the frozen balance of from is used for the transfer a TokenUnfrozen event must be emitted. 
    * The function MUST emit a Transfer event. 
    * The data parameter MAY be used to further document the action.
    */
    function forcedTransfer(address account, address to, uint256 value, bytes calldata data) external returns (bool);

}

interface IERC7551Compliance {
    /*
    * @notice This function return true if the message sender is able to transfer amount tokens to to respecting all compliance.
    * @dev Don't check the balance and the user's right (access control)
    */
    function canTransfer(address from, address to, uint256 value) external view returns (bool);

    /*
    * @notice This function return true if the message sender is able to transfer amount tokens to to respecting all compliance.
    * @dev Don't check the balance and the user's right (access control)
    */
    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    )  external view returns (bool);
}


interface IERC7551Base {
    /*
    * @notice Returns the metadata file
    */
    function metaData() external view returns (string memory);

    /*
    * @notice This function update the metaData value, generally an url
    */
    function setMetaData(string calldata metaData_) external;
}


