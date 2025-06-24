//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @notice standard interface to mint tokens
*/
interface IMintERC20 {
    /**
     * @dev Emitted when performing mint in batch with one specific value by account
     */
    event BatchMint(
        address indexed minter,
        address[] accounts,
        uint256[] values
    );
}

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
    * @notice allows the issuer to burn tokens from a frozen address
    */
  function forcedBurn(
        address account,
        uint256 value,
        bytes memory data
    ) external ;
}

/**
* @notice standard interface to burn tokens
*/
interface IBurnERC20 {
   /* ============ Events ============ */
   /**
     * @dev Emitted when performing burn in batch
     */
    event BatchBurn(
        address indexed burner,
        address[] accounts,
        uint256[] values,
        bytes data
    );
}
interface IBurnFromERC20 {
   /* ============ Events ============ */

    /**
    * @notice Emitted when the specified `spender` burns the specified `value` tokens owned by the specified `owner` reducing the corresponding allowance.
    */
    event BurnFrom(address indexed burner, address indexed account, address indexed spender, uint256 value);
  
  /*
  * @notice Burns `value` amount of tokens from `account`, deducting from the caller's
  * allowance.
  * @param account The address to burn tokens from.
  * @param value The number of tokens to be burned.
  * 
  **/
  function burnFrom(address account, uint256 value) external;

/*
* @notice Burns `value` amount of tokens from `msg.sender
* @param value The number of tokens to be burned.
* @dev the function must be restricted
**/
 function burn(uint256 value) external;
}