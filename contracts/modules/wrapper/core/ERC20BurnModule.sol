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
import {ICMTATBurn} from "../../../interfaces/tokenization/ICMTAT.sol";
/* ==== Other === */
import {Errors} from "../../../libraries/Errors.sol";
/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModule is ERC20Upgradeable, IERC20Allowance, IBurnERC20, ICMTATBurn, IERC3643Burn, IERC7551Burn, AuthorizationModule {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant BURNER_FROM_ROLE = keccak256("BURNER_FROM_ROLE");
    bytes32 public constant ENFORCER_ROLE_TRANSFER = keccak256("ENFORCER_ROLE_TRANSFER");
    
    /* ============ Events ============ */
    /**
    * @notice Emitted when the specified `spender` burns the specified `value` tokens owned by the specified `owner` reducing the corresponding allowance.
    */
    event BurnFrom(address indexed owner, address indexed spender, uint256 value);

    /* ============  Initializer Function ============ */
    function __ERC20BurnModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

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
     * @notice {burn} withtout reason
     * @dev
     * More standard burn function for compatibility
     */
    function burn(
        address account,
        uint256 value
    ) public virtual override(IERC3643Burn, IBurnERC20, ICMTATBurn) onlyRole(BURNER_ROLE) {
        _burn(account, value, "");
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
     * See {IERC3643Burn}
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
     * @notice Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     * @dev 
     * Can be used to authorize a bridge (e.g. CCIP) to burn token owned by the bridge
     * No data parameter reason to be compatible with Bridge, e.g. CCIP
     * 
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value)
        public override(IBurnERC20)
        onlyRole(BURNER_FROM_ROLE)
    {
        // Allowance check
        address sender =  _msgSender();
        ERC20Upgradeable._spendAllowance(account, sender, value );
        // burn
        // We also emit a burn event since its a burn operation
        _burn(account, value, "burnFrom");
        // Specific event for the operation
        emit BurnFrom(account, sender, value);
        emit Spend(account, sender, value);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev internal function to burn in batch
    */
    function _batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        bytes memory data
    ) internal virtual {
        require(accounts.length != 0, Errors.CMTAT_BurnModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), Errors.CMTAT_BurnModule_AccountsValueslengthMismatch());
        for (uint256 i = 0; i < accounts.length; ++i ) {
            _burn(accounts[i], values[i], data);
        }
    }

    /**
    * @dev internal function to burn
    */
    function _burn(
        address account,
        uint256 value,
        bytes memory data
    ) internal virtual {
        _burn(account, value);
        emit Burn(account, value, data);
    }
}
