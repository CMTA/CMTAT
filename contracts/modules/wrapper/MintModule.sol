//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../BaseModule.sol";

abstract contract MintModule is BaseModule{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event Mint(address indexed beneficiary, uint256 amount);

     /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        emit Mint(to, amount);
    }
}