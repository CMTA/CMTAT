//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../security/AuthorizationModule.sol";

abstract contract MintModule is ERC20Upgradeable, AuthorizationModule {
    event Mint(address indexed beneficiary, uint256 amount);

    function __MintModule_init(
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
        __MintModule_init_unchained();
    }

    function __MintModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        emit Mint(to, amount);
    }

    /**
     *
     * @dev batch version of {mint}.
     *
     * See {ERC20-_mint} and {OpenZeppelin ERC1155_mintBatch}.
     *
     * Emits a {Mint} event.
     *
     * Requirements:
     * - `tos` and `amounts` must have the same length
     * - the caller must have the `MINTER_ROLE`.
     */
    function mintBatch(
        address[] calldata tos,
        uint256[] calldata amounts
    ) public onlyRole(MINTER_ROLE) {
        require(
            tos.length > 0,
            "CMTAT: tos is empty"
        );
        // We do not check that amounts is not empty since
        // this require will throw an error in this case.
        require(
            tos.length == amounts.length,
            "CMTAT: tos and amounts length mismatch"
        );

        for (uint256 i = 0; i < tos.length; ) {
            _mint(tos[i], amounts[i]);
            emit Mint(tos[i], amounts[i]);
            unchecked {
                ++i;
            }
        }
    }

    uint256[50] private __gap;
}
