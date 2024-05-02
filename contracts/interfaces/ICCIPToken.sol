//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @notice CCIP Pool with mint
*/
interface ICCIPMintERC20 {
  /// @notice Mints new tokens for a given address.
  /// @param account The address to mint the new tokens to.
  /// @param value The number of tokens to be minted.
  /// @dev this function increases the total supply.
  function mint(address account, uint256 value) external;
}

/**
* @notice CCIP Pool with burnFrom
*/
interface ICCIPBurnFromERC20 {
  /// @notice Burns tokens from a given address..
  /// @param account The address to burn tokens from.
  /// @param value The number of tokens to be burned.
  /// @dev this function decreases the total supply.
  function burnFrom(address account, uint256 value) external;
}