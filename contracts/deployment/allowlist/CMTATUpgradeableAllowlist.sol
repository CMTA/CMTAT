//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseAllowlist} from "../../modules/CMTATBaseAllowlist.sol";
import {MetaTxModule, ERC2771ContextUpgradeable} from "../../modules/wrapper/options/MetaTxModule.sol";


/**
* @title CMTAT version for a proxy deployment (Transparent or Beacon proxy)
*/
contract CMTATUpgradeableAllowlist is CMTATBaseAllowlist {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address forwarderIrrevocable) MetaTxModule(forwarderIrrevocable) {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }
}
