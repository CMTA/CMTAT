//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {IBurnFromERC20} from "../../../interfaces/IMintToken.sol";
import {IERC3643Burn} from "../../../interfaces/IERC3643Partial.sol";
import {IERC20Allowance} from "../../../interfaces/IERC20Allowance.sol";
import {Errors} from "../../../libraries/Errors.sol";
/**
 * @title ERC20Burn module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20BurnModule is ERC20Upgradeable, IERC20Allowance, IBurnFromERC20, IERC3643Burn, AuthorizationModule {
    /* ============ State Variables ============ */
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant BURNER_FROM_ROLE = keccak256("BURNER_FROM_ROLE");
    bytes32 public constant ENFORCER_ROLE_TRANSFER = keccak256("ENFORCER_ROLE_TRANSFER");
    
    /* ============ Events ============ */
    /**
    * @notice Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `reason`
    */
    event Burn(address indexed owner, uint256 value, string reason);
    /**
    * @notice Emitted when the specified `spender` burns the specified `value` tokens owned by the specified `owner` reducing the corresponding allowance.
    */
    event BurnFrom(address indexed owner, address indexed spender, uint256 value);
    /**
    * @notice Emitted when a transfer is forced.
    */
    event Enforcement (address indexed enforcer, address indexed account, uint256 amount, string reason);

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
        _burnCommon(account, value,reason);
    }

    /**
     * @notice {burn} withtout reason
     * @dev
     * More standard burn function for compatibility
     */
    function burn(
        address account,
        uint256 value
    ) public onlyRole(BURNER_ROLE) {
        _burnCommon(account, value,"");
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
    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        string calldata reason
    ) public onlyRole(BURNER_ROLE) {
        _batchBurn(accounts, values, reason);
    }

    function batchBurn(
        address[] calldata accounts,
        uint256[] calldata values
    ) public onlyRole(BURNER_ROLE) {
        _batchBurn(accounts, values, "");
    }

    function _batchBurn(
        address[] calldata accounts,
        uint256[] calldata values,
        string memory reason
    ) internal {
        require(accounts.length != 0, Errors.CMTAT_BurnModule_EmptyAccounts());
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        require(bool(accounts.length == values.length), Errors.CMTAT_BurnModule_AccountsValueslengthMismatch());
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
        ERC20Upgradeable._spendAllowance(account, sender, value );
        // burn
        // We also emit a burn event since its a burn operation
        _burnCommon(account, value, "burnFrom");
        // Specific event for the operation
        emit BurnFrom(account, sender, value);
        emit Spend(account, sender, value);
    }


    /* ============  ERC-20 Enforcement ============ */
    /**
    * @notice Triggers a forced transfer.
    *
    */
    function forcedTransfer(address account, address destination, uint256 value, string calldata reason) public onlyRole(ENFORCER_ROLE_TRANSFER) {
       _forceTransfer(account, destination, value, reason);
    }

    /**
    * @notice Triggers a forced transfer.
    *
    */
    function forcedTransfer(address account, address destination, uint256 value) public  onlyRole(ENFORCER_ROLE_TRANSFER) returns (bool)  {
       _forceTransfer(account, destination, value, "");
       return true;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @notice internal function to burn
    */
    function _burnCommon(
        address account,
        uint256 value,
        string memory reason
    ) internal {
        _burn(account, value);
        emit Burn(account, value, reason);
    }

    function _forceTransfer(address account, address destination, uint256 value, string memory reason) internal {
       _transfer(account, destination, value);
        emit Enforcement(_msgSender(), account, value, reason);
    }
}
