//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../security/AuthorizationModule.sol";

abstract contract BurnModule is ERC20Upgradeable, AuthorizationModule {
    /**
     * @notice Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `reason`
     */
    event Burn(address indexed owner, uint256 value, string reason);

    function __BurnModule_init(
        string memory name_,
        string memory symbol_,
        address admin,
        uint48 initialDelayToAcceptAdminRole
    ) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __AccessControlDefaultAdminRules_init_unchained( initialDelayToAcceptAdminRole, admin);
        /* CMTAT modules */
        // Security
        __AuthorizationModule_init_unchained();

        // own function
        __BurnModule_init_unchained();
    }

    function __BurnModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @notice Destroys a `value` amount of tokens from `account`, by transferring it to address(0).
     * @dev
     * See {ERC20-_burn}
     * Emits a {Burn} event
     * Emits a {Transfer} event with `to` set to the zero address  (emits inside _burn).
     * Requirements:
     * - the caller must have the `BURNER_ROLE`.
     */
    function forceBurn(
        address account,
        uint256 value,
        string memory reason
    ) public onlyRole(BURNER_ROLE) {
        _burn(account, value);
        emit Burn(account, value, reason);
    }

    /**
     *
     * @notice batch version of {forceBurn}.
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
    function forceBurnBatch(
        address[] calldata accounts,
        uint256[] calldata values,
        string memory reason
    ) public onlyRole(BURNER_ROLE) {
        if (accounts.length == 0) {
            revert Errors.CMTAT_BurnModule_EmptyAccounts();
        }
        // We do not check that values is not empty since
        // this require will throw an error in this case.
        if (bool(accounts.length != values.length)) {
            revert Errors.CMTAT_BurnModule_AccountsValueslengthMismatch();
        }

        for (uint256 i = 0; i < accounts.length; ) {
            _burn(accounts[i], values[i]);
            emit Burn(accounts[i], values[i], reason);
            unchecked {
                ++i;
            }
        }
    }

    uint256[50] private __gap;
}
