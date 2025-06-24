//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
/* ==== Module === */
import {ERC20BurnModuleInternal} from "../../internal/ERC20BurnModuleInternal.sol";
/* ==== Technical === */
import {IBurnERC20} from "../../../interfaces/technical/IMintBurnToken.sol";
/* ==== Tokenization === */
import {IERC3643Burn} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Burn} from "../../../interfaces/tokenization/draft-IERC7551.sol";
/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModule is  ERC20BurnModuleInternal, AccessControlUpgradeable, IBurnERC20, IERC3643Burn, IERC7551Burn {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Destroys a `value` amount of tokens from `account`, by transferring it to address(0).
     * @dev
     * See {ERC20-_burn}
     * Emits a {Burn} event
     * Emits a {Transfer} event with `to` set to the zero address  (emits inside _burn).
     * Requirements:
     * - the caller must have the `BURNER_ROLE`.
     */
    function burn(
        address account,
        uint256 value,
        bytes calldata data
    ) public virtual override(IERC7551Burn) onlyRole(BURNER_ROLE) {
        _burn(account, value, data);
    }

    /**
     * @inheritdoc IERC3643Burn
     * @dev
     * More standard burn function for compatibility
     */
    function burn(
        address account,
        uint256 value
    ) public virtual override(IERC3643Burn) onlyRole(BURNER_ROLE) {
       _burn(account, value,"");
    }

    /**
     *
     * @notice batch version of {burn}.
     * @dev
     * See {ERC20-_burn}
     *
     * For each burn action:
     * -Emits a {Burn} event
     * -Emits a {Transfer} event with `to` set to the zero address  (emits inside _burn).
     * The burn `reason`is the same for all `accounts` which tokens are burnt.
     * Requirements:
     * - `accounts` and `values` must have the same length
     * - the caller must have the `BURNER_ROLE`.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        bytes memory data
    ) public virtual onlyRole(BURNER_ROLE) {
        _batchBurn(accounts, values);
        emit BatchBurn(_msgSender(),accounts, values, data );
    }

    /**
     *
     * @notice batch version of {burn}.
     * @dev
     * See {IERC3643Burn}t
     *
     * For each burn action:
     * -Emits a {Burn} event
     * -Emits a {Transfer} event with `to` set to the zero address  (emits inside _burn).
     * Requirements:
     * - `accounts` and `values` must have the same length
     * - the caller must have the `BURNER_ROLE`.
     */
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values
    ) public virtual override (IERC3643Burn) onlyRole(BURNER_ROLE) {
        _batchBurn(accounts, values);
        emit BatchBurn(_msgSender(),accounts, values, "" );
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _burn(
        address account,
        uint256 value,
        bytes memory data
    ) internal virtual {
        _burnOverride(account, value);
        emit Burn(_msgSender(), account, value, data);
    }
}
