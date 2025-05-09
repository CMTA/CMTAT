//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @notice standard interface to mint tokens
*/
/*interface IMintERC20 {
  /// @notice Mints new tokens for a given address.
  /// @param account The address to mint the new tokens to.
  /// @param value The number of tokens to be minted.
  /// @dev this function increases the total supply.
  function mint(address account, uint256 value) external;
}*/

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
    event BurnFrom(address indexed owner, address indexed spender, uint256 value);
  
  /// 
  /// @param account The address to burn tokens from.
  /// @param value The number of tokens to be burned.
  /// 
  /*
  * @notice Burns `value` amount of tokens from `account`, deducting from the caller's
  * allowance.
  * @param account The address to burn tokens from.
  * @param value The number of tokens to be burned.
  * 
  **/
  function burnFrom(address account, uint256 value) external;
}