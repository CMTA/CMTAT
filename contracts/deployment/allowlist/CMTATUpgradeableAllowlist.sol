//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseAllowlist} from "../../modules/2_CMTATBaseAllowlist.sol";
import {ERC2771Module, ERC2771ContextUpgradeable} from "../../modules/wrapper/options/ERC2771Module.sol";


/**
* @title CMTAT version for a proxy deployment (Transparent or Beacon proxy)
*/
contract CMTATUpgradeableAllowlist is CMTATBaseAllowlist {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address forwarderIrrevocable) ERC2771Module(forwarderIrrevocable) {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }
}
