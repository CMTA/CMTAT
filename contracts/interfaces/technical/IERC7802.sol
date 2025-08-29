// SPDX-License-Identifier: MIT
// From https://github.com/ethereum-optimism/optimism/blob/op-node/v1.13.2/packages/contracts-bedrock/interfaces/L2/IERC7802.sol
pragma solidity ^0.8.20;

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

/**
* @title IERC7802
* @notice Defines the interface for crosschain ERC20 transfers.
*/
interface IERC7802 is IERC165 {
    /** 
    * @notice Emitted when a crosschain transfer mints tokens.
    * @param to       Address of the account tokens are being minted for.
    * @param value   Amount of tokens minted.
    * @param sender   Address of the account that finalized the crosschain transfer.
    */
    event CrosschainMint(address indexed to, uint256 value, address indexed sender);

    /**
    * @notice Emitted when a crosschain transfer burns tokens.
    * @param from     Address of the account tokens are being burned from.
    * @param value Amount of tokens burned.
    * @param sender   Address of the account that initiated the crosschain transfer.
    */
    event CrosschainBurn(address indexed from, uint256 value, address indexed sender);

    /** 
    * @notice Mint tokens through a crosschain transfer.
    * @param to     Address to mint tokens to.
    * @param value Amount of tokens to mint.
    */
    function crosschainMint(address to, uint256 value) external;

    /**
    * @notice Burn tokens through a crosschain transfer.
    * @param from  Address to burn tokens from.
    * @param value Amount of tokens to burn.
    */
    function crosschainBurn(address from, uint256 value) external;
}