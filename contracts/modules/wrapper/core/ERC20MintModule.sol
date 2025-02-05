//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {ICCIPMintERC20} from "../../../interfaces/ICCIPToken.sol";
import {Errors} from "../../../libraries/Errors.sol";
/**
 * @title ERC20Mint module.
 * @dev 
 *
 * Contains all mint functions, inherits from ERC-20
 */
abstract contract ERC20MintModule is ERC20Upgradeable, ICCIPMintERC20, AuthorizationModule {
    /* ============ State Variables ============ */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    /* ============ Events ============ */
    /**
     * @notice Emitted when the specified  `value` amount of new tokens are created and
     * allocated to the specified `account`.
     */
    event Mint(address indexed account, uint256 value);


    /* ============  Initializer Function ============ */
    function __ERC20MintModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice  Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)
     * @param account token receiver
     * @param value amount of tokens
     * @dev
     * See {OpenZeppelin ERC20-_mint}.
     * Emits a {Mint} event.
     * Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     *
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * - The caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value) public onlyRole(MINTER_ROLE) {
        _mint(account, value);
        emit Mint(account, value);
    }

    /**
     *
     * @notice batch version of {mint}
     * @dev
     * See {OpenZeppelin ERC20-_mint} and {OpenZeppelin ERC1155_mintBatch}.
     *
     * For each mint action:
     * - Emits a {Mint} event.
     * - Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     *
     * Requirements:
     * - `accounts` and `values` must have the same length
     * - `accounts` cannot contain a zero address (check made by _mint).
     * - the caller must have the `MINTER_ROLE`.
     */
    function mintBatch(
        address[] calldata accounts,
        uint256[] calldata values
    ) public onlyRole(MINTER_ROLE) {
        if (accounts.length == 0) {
            revert Errors.CMTAT_MintModule_EmptyAccounts();
        }
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        if (bool(accounts.length != values.length)) {
            revert Errors.CMTAT_MintModule_AccountsValueslengthMismatch();
        }
        // No need of unchecked block since Soliditiy 0.8.22
        for (uint256 i = 0; i < accounts.length; ++i ) {
            _mint(accounts[i], values[i]);
            emit Mint(accounts[i], values[i]);
        }
    }
}
