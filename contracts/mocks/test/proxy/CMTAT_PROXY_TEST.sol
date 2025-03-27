//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTAT_PROXY} from "../../../deployment/CMTAT_PROXY.sol";


/**
 * @title a contrat used to test the proxy upgrade functionality
 */
contract CMTAT_PROXY_TEST is CMTAT_PROXY {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) CMTAT_PROXY(forwarderIrrevocable) {
        // Nothing to do
    }
}
