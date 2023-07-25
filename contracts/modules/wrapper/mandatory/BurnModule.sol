//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../security/AuthorizationModule.sol";

abstract contract BurnModule is ERC20Upgradeable, AuthorizationModule {
    event Burn(address indexed owner, uint256 amount, string reason);

    function __BurnModule_init(
        string memory name_,
        string memory symbol_,
        address admin
    ) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();

        /* CMTAT modules */
        // Security
        __AuthorizationModule_init_unchained(admin);

        // own function
        __BurnModule_init_unchained();
    }

    function __BurnModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @dev Destroys `amount` tokens from `account`
     *
     * See {ERC20-_burn}
     * Emits a {Burn} event
     */
    function forceBurn(
        address account,
        uint256 amount,
        string memory reason
    ) public onlyRole(BURNER_ROLE) {
        _burn(account, amount);
        emit Burn(account, amount, reason);
    }

    /**
     *
     * @dev batch version of {burn}.
     *
     * See {ERC20-_burn} and {OpenZeppelin ERC1155_burnBatch}.
     *
     * Emits a {Burn} event by burn action.
     *
     * Requirements:
     *
     * - the caller must have the `BURNER_ROLE`.
     */
    function forceBurnBatch(
        address[] calldata accounts,
        uint256[] calldata amounts,
        string memory reason
    ) public onlyRole(BURNER_ROLE) {
        require(
            accounts.length == amounts.length,
            "CMTAT: accounts and amounts length mismatch"
        );

        for (uint256 i = 0; i < accounts.length; ) {
            _burn(accounts[i], amounts[i]);
            emit Burn(accounts[i], amounts[i], reason);
            unchecked {
                ++i;
            }
        }
    }

    uint256[50] private __gap;
}
