// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ERC20MintModuleInternal} from "../../internal/ERC20MintModuleInternal.sol";
/* ==== Technical === */
import {IMintBatchERC20Event} from "../../../interfaces/technical/IMintBurnToken.sol";
/* ==== Tokenization === */
import {IERC3643Mint, IERC3643BatchTransfer} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Mint, IERC5679Mint} from "../../../interfaces/tokenization/draft-IERC7551.sol";

/**
 * @title ERC20Mint module.
 * @dev 
 *
 * Contains all mint functions, inherits from ERC-20
 */
abstract contract ERC20MintModule is  ERC20MintModuleInternal, IERC3643Mint, IERC3643BatchTransfer, IERC7551Mint, IMintBatchERC20Event {

    /* ============ State Variables ============ */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");


    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the burner functions
    modifier onlyMinter() {
        _authorizeMint();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @inheritdoc IERC5679Mint
     * @custom:devimpl
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value, bytes calldata data) public virtual override(IERC5679Mint) onlyMinter {
        _mint(account, value, data);
    }

    /**
     * @inheritdoc IERC3643Mint
     * @dev

     * Emits a {Mint} event.
     * Emits a {Transfer} event with `from` set to the zero address (emits inside _mint).
     *
     * Requirements:
     * - `account` cannot be the zero address (check made by _mint).
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address account, uint256 value) public virtual override(IERC3643Mint) onlyMinter {
       _mint(account, value, "");
    }

    /**
     *
     * @inheritdoc IERC3643Mint
     * @custom:devimpl
     * Requirement 
     * - `accounts` cannot contain a zero address (check made by _mint).
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
    function batchMint(
        address[] calldata accounts,
        uint256[] calldata values
    ) public virtual override(IERC3643Mint) onlyMinter{
       _batchMint(accounts, values);
        emit BatchMint(_msgSender(), accounts, values);
    }
    
    /**
     * @inheritdoc IERC3643BatchTransfer
     * @custom:access-control
     * - the caller must have the `MINTER_ROLE`.
     */
   function batchTransfer(
        address[] calldata tos,
        uint256[] calldata values
    ) public virtual override(IERC3643BatchTransfer) onlyMinter returns (bool success_) {
        return _batchTransfer(tos, values);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _mint(address account, uint256 value, bytes memory data) internal virtual {
        _mintOverride(account, value);
        emit Mint(_msgSender(), account, value, data);
    }
    /* ============ Access Control ============ */
    function _authorizeMint() internal virtual;
}
