// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
/* ==== Tokenization === */
import {IERC3643ERC20Base} from "../../../interfaces/tokenization/IERC3643Partial.sol";

/**
 * @title TokenAttribute module
 * @dev
 *
 * Manages the mutable token attributes (name and symbol) independently of the
 * underlying token standard (ERC-20, ERC-7984, ...).
 *
 * The attributes are stored in this module's own ERC-7201 namespaced storage, so
 * a contract that also inherits a token standard (e.g. `ERC20Upgradeable`) only
 * has to override that standard's `name()` / `symbol()` to delegate here. This
 * keeps the metadata management reusable by non ERC-20 (e.g. confidential) tokens.
 */
abstract contract TokenAttributeModule is Initializable, IERC3643ERC20Base {
    /* ============ Events ============ */
    event Name(string indexed newNameIndexed, string newName);
    event Symbol(string indexed newSymbolIndexed, string newSymbol);

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.TokenAttributeModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TokenAttributeModuleStorageLocation = 0xc541cfc06cfa9bb7e38e614bc9457bd7310b58a2a620e4f19164873143c76d00;
    /* ==== ERC-7201 State Variables === */
    struct TokenAttributeModuleStorage {
        // We don't use the underlying token standard's name/symbol because we can not modify them
        string _name;
        string _symbol;
    }

    /* ============ Modifier ============ */
    modifier onlyTokenAttributeManager() {
        _authorizeTokenAttributeManagement();
        _;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev Initializers: sets the token name and symbol.
     */
    function __TokenAttributeModule_init_unchained(
        string memory name_,
        string memory symbol_
    ) internal virtual onlyInitializing {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        $._name = name_;
        $._symbol = symbol_;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ======== View functions ======= */
    /**
     * @notice Returns the name of the token.
     * @return The token name.
     */
    function name() public view virtual returns (string memory) {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        return $._name;
    }

    /**
     * @notice Returns the symbol of the token, usually a shorter version of the name.
     * @return The token symbol.
     */
    function symbol() public view virtual returns (string memory) {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        return $._symbol;
    }

    /* ======== State functions ======= */
    /**
     *  @inheritdoc IERC3643ERC20Base
     */
    function setName(string calldata name_) public virtual override(IERC3643ERC20Base) onlyTokenAttributeManager {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        $._name = name_;
        emit Name(name_, name_);
    }

    /**
     * @inheritdoc IERC3643ERC20Base
     */
    function setSymbol(string calldata symbol_) public virtual override(IERC3643ERC20Base) onlyTokenAttributeManager {
        TokenAttributeModuleStorage storage $ = _getTokenAttributeModuleStorage();
        $._symbol = symbol_;
        emit Symbol(symbol_, symbol_);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ Access Control ============ */
    function _authorizeTokenAttributeManagement() internal virtual;

    /* ============ ERC-7201 ============ */
    function _getTokenAttributeModuleStorage() private pure returns (TokenAttributeModuleStorage storage $) {
        assembly {
            $.slot := TokenAttributeModuleStorageLocation
        }
    }
}
