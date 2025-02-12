//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
// required OZ imports here
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {Errors} from "../../../libraries/Errors.sol";

/**
 * @title ERC20Base module
 * @dev 
 *
 * Contains ERC-20 base functions and extension
 * Inherits from ERC-20
 * 
 */
abstract contract ERC20BaseModule is ERC20Upgradeable, AuthorizationModule {
     /* ============ State Variables ============ */
    bytes32 public constant ENFORCER_ROLE_TRANSFER = keccak256("ENFORCER_ROLE_TRANSFER");
    /* ============ Events ============ */
    /**
    * @notice Emitted when a transfer is forced.
    */
    event Enforcement (address indexed enforcer, address indexed account, uint256 amount, string reason);
    /**
    * @notice Emitted when the specified `spender` spends the specified `value` tokens owned by the specified `owner` reducing the corresponding allowance.
    * @dev The allowance can be also "spend" with the function BurnFrom, but in this case, the emitted event is BurnFrom.
    */
    event Spend(address indexed owner, address indexed spender, uint256 value);
    event Name(string indexed newNameIndexed, string newName);
    event Symbol(string indexed newSymbolIndexed, string newSymbol);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20BaseModuleStorageLocation = 0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00;
    /* ==== ERC-7201 State Variables === */
    struct ERC20BaseModuleStorage {
        uint8 _decimals;
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
    ) internal onlyInitializing {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._decimals = decimals_;
        $._symbol = symbol_;
        $._name = name_;
    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============  ERC-20 standard ============ */
    /**
     *
     * @notice Returns the number of decimals used to get its user representation.
     * @inheritdoc ERC20Upgradeable
     */
    function decimals() public view virtual override returns (uint8) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._decimals;
    }

    /**
     * @notice Transfers `value` amount of tokens from address `from` to address `to`
     * @custom:dev-cmtat
     * Emits a {Spend} event indicating the spended allowance.
     * @inheritdoc ERC20Upgradeable
     *
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override returns (bool) {
        bool result = ERC20Upgradeable.transferFrom(from, to, value);
        // The result will be normally always true because OpenZeppelin will revert in case of an error
        if (result) {
            emit Spend(from, _msgSender(), value);
        }

        return result;
    }



    /**
     * @notice Returns the name of the token.
     */
    function name() public virtual override view returns (string memory) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._name;
    }

    /**
     * @notice  Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public virtual override view returns (string memory) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        return $._symbol;
    }


    /* ============  Custom functions ============ */

    /**
     * @notice batch version of transfer
     * @param tos can not be empty, must have the same length as values
     * @param values can not be empty
     * @dev See {OpenZeppelin ERC20-transfer & ERC1155-safeBatchTransferFrom}.
     *
     *
     * Requirements:
     * - `tos` and `values` must have the same length
     * - `tos`cannot contain a zero address (check made by transfer)
     * - the caller must have a balance cooresponding to the total values
     */
    function transferBatch(
        address[] calldata tos,
        uint256[] calldata values
    ) public returns (bool) {
        if (tos.length == 0) {
            revert Errors.CMTAT_ERC20BaseModule_EmptyTos();
        }
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        if (bool(tos.length != values.length)) {
            revert Errors.CMTAT_ERC20BaseModule_TosValueslengthMismatch();
        }
        // No need of unchecked block since Soliditiy 0.8.22
        for (uint256 i = 0; i < tos.length; ++i) {
            // We call directly the internal function transfer
            // The reason is that the public function adds only the owner address recovery
            ERC20Upgradeable._transfer(_msgSender(), tos[i], values[i]);
        }
        // not really useful
        // Here only to keep the same behaviour as transfer
        return true;
    }

    /**
    * @param addresses list of address to know their balance
    * @return balances ,totalSupply array with balance for each address, totalSupply
    * @dev useful to distribute dividend and to perform on-chain snapshot
    */
    function balanceInfo(address[] calldata addresses) public view returns(uint256[] memory balances , uint256 totalSupply) {
        balances = new uint256[](addresses.length);
        for(uint256 i = 0; i < addresses.length; ++i){
            balances[i] = ERC20Upgradeable.balanceOf(addresses[i]);
        }
        totalSupply = ERC20Upgradeable.totalSupply();
    }

    /* ============  Restricted Functions ============ */
    /**
     *  @dev See {IToken-setName}.
     */
    function setName(string calldata name_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._name = name_;
        emit Name(name_, name_);
    }

    /**
     *  @dev See {IToken-setSymbol}.
     */
    function setSymbol(string calldata symbol_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._symbol = symbol_;
        emit Symbol(symbol_, symbol_);
    }
    
    /* ============  ERC-20 Enforcement ============ */
    /**
    * @notice Triggers a forced transfer.
    *
    */
  function enforceTransfer(address account, address destination, uint256 value, string calldata reason) public onlyRole(ENFORCER_ROLE_TRANSFER) {
       _transfer(account, destination, value);
        emit Enforcement(_msgSender(), account, value, reason);
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
