//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// required OZ imports here
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "../../../libraries/Errors.sol";

abstract contract ERC20BaseModule is ERC20Upgradeable {
    /* ============ Events ============ */
    /**
    * @notice Emitted when the specified `spender` spends the specified `value` tokens owned by the specified `owner` reducing the corresponding allowance.
    * @dev The allowance can be also "spend" with the function BurnFrom, but in this case, the emitted event is BurnFrom.
    */
    event Spend(address indexed owner, address indexed spender, uint256 value);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20BaseModuleStorageLocation = 0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00;
    /* ==== ERC-7201 State Variables === */
    struct ERC20BaseModuleStorage {
        uint8 _decimals;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev Initializers: Sets the values for decimals.
     *
     * this value is immutable: it can only be set once during
     * construction/initialization.
     */
    function __ERC20BaseModule_init_unchained(
        uint8 decimals_
    ) internal onlyInitializing {
        ERC20BaseModuleStorage storage $ = _getERC20BaseModuleStorage();
        $._decimals = decimals_;
    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
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
    * @param addresses list of address to know their balance
    * @return balances ,totalSupply array with balance for each address, totalSupply
    * @dev useful for the snapshot rule
    */
    function balanceInfo(address[] calldata addresses) public view returns(uint256[] memory balances , uint256 totalSupply) {
        balances = new uint256[](addresses.length);
        for(uint256 i = 0; i < addresses.length; ++i){
            balances[i] = ERC20Upgradeable.balanceOf(addresses[i]);
        }
        totalSupply = ERC20Upgradeable.totalSupply();
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
