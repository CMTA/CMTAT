//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// required OZ imports here
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../../../libraries/Errors.sol";

abstract contract ERC20BaseModule is ERC20Upgradeable {
    /* Events */
    /**
    * @notice Emitted when the specified `spender` spends the specified `value` tokens owned by the specified `owner` reducing the corresponding allowance.
    * @dev The allowance can be also "spend" with the function BurnFrom, but in this case, the emitted event is BurnFrom.
    */
    event Spend(address indexed owner, address indexed spender, uint256 value);

    /* Variables */
    uint8 private _decimals;

    /* Initializers */

    /**
     * @dev Sets the values for decimals.
     *
     * this value is immutable: it can only be set once during
     * construction/initialization.
     */
    function __ERC20BaseModule_init_unchained(
        uint8 decimals_
    ) internal onlyInitializing {
        _decimals = decimals_;
    }

    /* Methods */
    /**
     *
     * @notice Returns the number of decimals used to get its user representation.
     * @inheritdoc ERC20Upgradeable
     */
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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

        for (uint256 i = 0; i < tos.length; ) {
            // We call directly the internal function transfer
            // The reason is that the public function adds only the owner address recovery
            ERC20Upgradeable._transfer(_msgSender(), tos[i], values[i]);
            unchecked {
                ++i;
            }
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

    uint256[50] private __gap;
}
