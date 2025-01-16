//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {ICCIPBurnFromERC20} from "../../../interfaces/ICCIPToken.sol";
import {Errors} from "../../../libraries/Errors.sol";
/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModule is ERC20Upgradeable, ICCIPBurnFromERC20, AuthorizationModule {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant BURNER_FROM_ROLE = keccak256("BURNER_FROM_ROLE");
    
    /* ============ Events ============ */
    /**
    * @notice Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `reason`
    */
    event Burn(address indexed owner, uint256 value, string reason);
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
        string calldata reason
    ) public onlyRole(BURNER_ROLE) {
        _burn(account, value);
        emit Burn(account, value, reason);
    }


    /**
     *
     * @notice batch version of {burn}.
     * @dev
     * See {ERC20-_burn} and {OpenZeppelin ERC1155_burnBatch}.
     *
     * For each burn action:
     * -Emits a {Burn} event
     * -Emits a {Transfer} event with `to` set to the zero address  (emits inside _burn).
     * The burn `reason`is the same for all `accounts` which tokens are burnt.
     * Requirements:
     * - `accounts` and `values` must have the same length
     * - the caller must have the `BURNER_ROLE`.
     */
    function burnBatch(
        address[] calldata accounts,
        uint256[] calldata values,
        string calldata reason
    ) public onlyRole(BURNER_ROLE) {
        if (accounts.length == 0) {
            revert Errors.CMTAT_BurnModule_EmptyAccounts();
        }
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        if (bool(accounts.length != values.length)) {
            revert Errors.CMTAT_BurnModule_AccountsValueslengthMismatch();
        }
        // No need of unchecked block since Soliditiy 0.8.22
        for (uint256 i = 0; i < accounts.length; ++i ) {
            _burn(accounts[i], values[i]);
            emit Burn(accounts[i], values[i], reason);
        }
    }

    /**
     * @notice Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     * @dev 
     * Can be used to authorize a bridge (e.g. CCIP) to burn token owned by the bridge
     * No string parameter reason to be compatible with Bridge, e.g. CCIP
     * 
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `value`.
     */
    function burnFrom(address account, uint256 value)
        public
        onlyRole(BURNER_FROM_ROLE)
    {
        // Allowance check
        address sender =  _msgSender();
        uint256 currentAllowance = allowance(account, sender);
        if(currentAllowance < value){
            // ERC-6093
            revert ERC20InsufficientAllowance(sender, currentAllowance, value);
        }
        // Update allowance
        unchecked {
            _approve(account, sender, currentAllowance - value);
        }
        // burn
        _burn(account, value);
        // We also emit a burn event since its a burn operation
        emit Burn(account, value, "burnFrom");
        // Specific event for the operation
        emit BurnFrom(account, sender, value);
    }
}
