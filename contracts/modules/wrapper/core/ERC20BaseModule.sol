//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
/* ==== Technical === */
import {IERC20Allowance} from "../../../interfaces/technical/IERC20Allowance.sol";
import {IERC20BatchBalance} from "../../../interfaces/engine/ISnapshotEngine.sol";
/* ==== Tokenization === */
import {IERC3643ERC20Base} from "../../../interfaces/tokenization/IERC3643Partial.sol";

/**
 * @title ERC20Base module
 * @dev 
 *
 * Contains ERC-20 base functions and extension
 * Inherits from ERC-20
 * 
 */
abstract contract ERC20BaseModule is ERC20Upgradeable, AccessControlUpgradeable, IERC20Allowance, IERC3643ERC20Base, IERC20BatchBalance{
    event Name(string indexed newNameIndexed, string newName);
    event Symbol(string indexed newSymbolIndexed, string newSymbol);

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20BaseModuleStorageLocation = 0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00;
    /* ==== ERC-7201 State Variables === */
    struct ERC20BaseModuleStorage {
        uint8 _decimals;
        // We don't use ERC20Upgradeable name and private because we can not modify them
        string _name;
        string _symbol;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev Initializers: Sets the values for decimals.
     *
     * this value is immutable: it can only be set once during
     * construction/initialization.
     */
    function __ERC20BaseModule_init_unchained(
        uint8 decimals_,
        string memory name_,
        string memory symbol_
    ) internal virtual onlyInitializing {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._decimals = decimals_;
        $._symbol = symbol_;
        $._name = name_;
    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============  ERC-20 standard ============ */
    
    /* ======== State functions ======= */
     /**
     * @notice Transfers `value` amount of tokens from address `from` to address `to`
     * @custom:devimpl
     * Emits a {Spend} event indicating the allowance spent.
     * @inheritdoc ERC20Upgradeable
     *
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override(ERC20Upgradeable) returns (bool) {
        bool result = ERC20Upgradeable.transferFrom(from, to, value);
        // The result will be normally always true because OpenZeppelin will revert in case of an error
        if (result) {
            emit Spend(from, _msgSender(), value);
        }

        return result;
    }

    /* ======== View functions ======= */
    /**
     *
     * @notice Returns the number of decimals used to get its user representation.
     * @inheritdoc ERC20Upgradeable
     */
    function decimals() public view virtual override(ERC20Upgradeable) returns (uint8) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._decimals;
    }

    /**
     * @notice Returns the name of the token.
     */
    function name() public virtual override(ERC20Upgradeable) view returns (string memory) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._name;
    }

    /**
     * @notice  Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public virtual override(ERC20Upgradeable) view returns (string memory) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._symbol;
    }


    /* ============  Custom functions ============ */
    /* ========  State Functions ======= */
    /**
     *  @inheritdoc IERC3643ERC20Base
     *  @dev 
     */
    function setName(string calldata name_) public virtual override(IERC3643ERC20Base) onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._name = name_;
        emit Name(name_, name_);
    }

    /**
     * @inheritdoc IERC3643ERC20Base
     */
    function setSymbol(string calldata symbol_) public virtual override(IERC3643ERC20Base) onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._symbol = symbol_;
        emit Symbol(symbol_, symbol_);
    }
    /* ======== View functions ======= */
    /**
    * @inheritdoc IERC20BatchBalance
    */
    function batchBalanceOf(address[] calldata addresses) public view virtual override(IERC20BatchBalance) returns(uint256[] memory balances , uint256 totalSupply_) {
        balances = new uint256[](addresses.length);
        for(uint256 i = 0; i < addresses.length; ++i){
            balances[i] = ERC20Upgradeable.balanceOf(addresses[i]);
        }
        totalSupply_ = ERC20Upgradeable.totalSupply();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /* ============ ERC-7201 ============ */
    function _getERC20BaseModuleStorage() private pure returns (ERC20BaseModuleStorage storage $) {
        assembly {
            $.slot := ERC20BaseModuleStorageLocation
        }
    }
}
