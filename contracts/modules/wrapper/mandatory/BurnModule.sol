//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../optional/AuthorizationModule.sol";

abstract contract BurnModule is ERC20Upgradeable, AuthorizationModule {
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    event Burn(address indexed owner, uint256 amount);

    function __BurnModule_init(string memory name_, string memory symbol_) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        
        /* Wrapper */
        __AuthorizationModule_init_unchained();

        /* own function */
        __BurnModule_init_unchained();
    }

    function __BurnModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @dev Destroys `amount` tokens from `account`
     *
     * See {ERC20-_burn}
     */
    function forceBurn(address account, uint256 amount)
        public
        onlyRole(BURNER_ROLE)
    {
        _burn(account, amount);
        emit Burn(account, amount);
    }

    uint256[50] private __gap;
}
