//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTAT_ERC1363_BASE} from "../../modules/CMTAT_ERC1363_BASE.sol";
import {CMTAT_BASE, MetaTxModule, ICMTATConstructor} from "../../modules/CMTAT_BASE.sol";
/**
* @title CMTAT Proxy version for ERC1363
*/
contract CMTAT_PROXY_ERC1363 is CMTAT_ERC1363_BASE {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) MetaTxModule(forwarderIrrevocable) {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }

}
