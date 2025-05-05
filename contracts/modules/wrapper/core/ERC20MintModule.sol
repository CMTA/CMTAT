//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Technical === */
import {IMintERC20} from "../../../interfaces/technical/IMintBurnToken.sol";
/* ==== Tokenization === */
import {IERC3643Mint} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Mint} from "../../../interfaces/tokenization/draft-IERC7551.sol";

/**
 * @title ERC20Mint module.
 * @dev 
 *
 * Contains all mint functions, inherits from ERC-20
 */
abstract contract ERC20MintModule is ERC20Upgradeable, IMintERC20, IERC3643Mint, IERC7551Mint, AuthorizationModule {
    error CMTAT_MintModule_EmptyAccounts();
    error CMTAT_MintModule_AccountsValueslengthMismatch();

    /* ============ State Variables ============ */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /**
     * @dev Emitted when performing mint in batch with the same value
     */
    event BatchMintSameValue(
        address indexed minter,
        address[] accounts,
        uint256 value
    );
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
     * See {OpenZeppelin ERC20-_mint} & {IERC7551Mint}.
     * Emits a {Mint} event.
     * Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     *
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * - The caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value, bytes calldata data) public virtual override(IERC7551Mint) onlyRole(MINTER_ROLE) {
        _mint(account, value, data);
    }

    /**
     * @notice  Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)
     * @param account token receiver
     * @param value amount of tokens
     * @dev
     * See {OpenZeppelin ERC20-_mint} & {IERC3643Mint}.
     * Emits a {Mint} event.
     * Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     *
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * - The caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value) public virtual override(IERC3643Mint, IMintERC20) onlyRole(MINTER_ROLE) {
        _mint(account, value, "");
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
    function batchMint(
        address[] calldata accounts,
        uint256[] calldata values
    ) public virtual override(IERC3643Mint) onlyRole(MINTER_ROLE) {
        require(accounts.length > 0, CMTAT_MintModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), CMTAT_MintModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
            _mint(accounts[i], values[i], "");
        }
    }

    /**
     *
     * @notice batch version of {mint} with the same `value` amount of tokens minted for each account
     * @dev
     *
     * For each mint action, emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     * Emits a {BatchMintSameValue} event.
     * Requirements:
     * - `accounts` cannot be empty (error Mint_EmptyAccounts)
     * - `accounts` cannot contain a zero address (check made by _mint, error ERC20InvalidReceiver).
     * -  the caller must have the `MINTER_ROLE` (error AccessControlUnauthorizedAccount)
     */
    function batchMintSameValue(
        address[] calldata accounts,
        uint256 value
    ) public virtual onlyRole(MINTER_ROLE) {
        require(accounts.length != 0, CMTAT_MintModule_EmptyAccounts());
        for (uint256 i = 0; i < accounts.length; ++i) {
            _mint(accounts[i], value);
        }
        emit BatchMintSameValue(msg.sender, accounts, value);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _mint(address account, uint256 value, bytes memory data) internal virtual {
        _mint(account, value);
        emit Mint(account, value, data);
    }

}
