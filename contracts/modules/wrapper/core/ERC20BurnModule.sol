//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Technical === */
import {IBurnERC20} from "../../../interfaces/technical/IMintBurnToken.sol";
import {IERC20Allowance} from "../../../interfaces/technical/IERC20Allowance.sol";
/* ==== Tokenization === */
import {IERC3643Burn} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Burn} from "../../../interfaces/tokenization/draft-IERC7551.sol";
/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModule is ERC20Upgradeable, IERC20Allowance, IBurnERC20, IERC3643Burn, IERC7551Burn, AuthorizationModule {
    error CMTAT_BurnModule_EmptyAccounts();
    error CMTAT_BurnModule_AccountsValueslengthMismatch();

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
        _batchBurn(accounts, values, data);
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
        _batchBurn(accounts, values, "");
    }


    /**
    * @dev internal function to burn in batch
    */
    function _batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        bytes memory data
    ) internal virtual {
        require(accounts.length != 0, CMTAT_BurnModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), CMTAT_BurnModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
             _burnOverride(accounts[i], values[i]);
        }
        emit BatchBurn(_msgSender(),accounts, values, data );
    }

    /**
    * @dev Internal function to burn
    */
    function _burnOverride(
        address account,
        uint256 value
    ) internal virtual {
        ERC20Upgradeable._burn(account, value);
    }

    function _burn(
        address account,
        uint256 value,
        bytes memory data
    ) internal virtual {
        _burnOverride(account, value);
        emit Burn(_msgSender(), account, value, data);
    }
}
