//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

abstract contract AuthorizationModule is AccessControlUpgradeable {
    function __AuthorizationModule_init() internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        __AccessControl_init_unchained();

       /* own function */
        __AuthorizationModule_init_unchained();
    }

    function __AuthorizationModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    uint256[50] private __gap;
}
