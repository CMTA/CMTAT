//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Technical === */
//import {IMintERC20} from "../../../interfaces/technical/IMintBurnToken.sol";
/* ==== Tokenization === */
import {IERC3643Mint, IERC3643BatchTransfer} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Mint} from "../../../interfaces/tokenization/draft-IERC7551.sol";

/**
 * @title ERC20Mint module.
 * @dev 
 *
 * Contains all mint functions, inherits from ERC-20
 */
abstract contract ERC20MintModule is ERC20Upgradeable, IERC3643Mint, IERC3643BatchTransfer, IERC7551Mint, AuthorizationModule {
    error CMTAT_MintModule_EmptyAccounts();
    error CMTAT_MintModule_AccountsValueslengthMismatch();
    error CMTAT_MintModule_EmptyTos();
    error CMTAT_MintModule_TosValueslengthMismatch();

    /**
     * @dev Emitted when performing mint in batch with one specific value by account
     */
    event BatchMint(
        address indexed minter,
        address[] accounts,
        uint256[] values
    );
    /* ============ State Variables ============ */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /* ============  Initializer Function ============ */
    function __ERC20MintModule_init_unchained() internal virtual onlyInitializing {
        // no variable to initialize
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @inheritdoc IERC7551Mint
     * @notice  Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0)

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
     * @inheritdoc IERC3643Mint
     * @dev
     * See {OpenZeppelin ERC20-_mint} & {IERC3643Mint}.
     * Emits a {Mint} event.
     * Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     *
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * - The caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value) public virtual override(IERC3643Mint) onlyRole(MINTER_ROLE) {
       _mint(account, value, "");
    }

    /**
     *
     * @inheritdoc IERC3643Mint
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
       _batchMint(accounts, values);
    }
    
    /* inheritdoc IERC3643BatchTransfer
     * @dev See {OpenZeppelin ERC20-transfer}.
     *
     *
     * Requirements:
     * - `tos` and `values` must have the same length
     * - `tos`cannot contain a zero address (check made by transfer)
     * - the caller must have a balance cooresponding to the total values
     */
   function batchTransfer(
        address[] calldata tos,
        uint256[] calldata values
    ) public override(IERC3643BatchTransfer) onlyRole(MINTER_ROLE) returns (bool) {
        return _batchTransfer(tos, values);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _batchMint(
        address[] calldata accounts,
        uint256[] calldata values
    ) internal virtual {
        require(accounts.length > 0, CMTAT_MintModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), CMTAT_MintModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
            _mintOverride(accounts[i], values[i]);
        }
        emit BatchMint(_msgSender(), accounts, values);
    }
    function _batchTransfer(
        address[] calldata tos,
        uint256[] calldata values
    ) internal virtual returns (bool) {
        require(tos.length > 0, CMTAT_MintModule_EmptyTos());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(tos.length == values.length), CMTAT_MintModule_TosValueslengthMismatch());
        // No need of unchecked block since Soliditiy 0.8.22
        for (uint256 i = 0; i < tos.length; ++i) {
            // We call directly the internal OpenZeppelin function _transfer
            // The reason is that the public function adds only the owner address recovery
            ERC20Upgradeable._transfer(_msgSender(), tos[i], values[i]);
        }
        // not really useful
        // Here only to keep the same behaviour as transfer
        return true;
    }
    function _mintOverride(address account, uint256 value) internal virtual {
        ERC20Upgradeable._mint(account, value);
    }

      function _mint(address account, uint256 value, bytes memory data) internal virtual {
        _mintOverride(account, value);
        emit Mint(account, value, data);
      }

}
