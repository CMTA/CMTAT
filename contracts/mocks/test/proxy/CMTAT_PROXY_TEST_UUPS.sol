//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTAT_PROXY_UUPS} from "../../../deployment/CMTAT_PROXY_UUPS.sol";


/**
 * @title a contrat used to test the proxy upgrade functionality
 */
contract CMTAT_PROXY_TEST_UUPS is CMTAT_PROXY_UUPS {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) CMTAT_PROXY_UUPS(forwarderIrrevocable) {
        // Nothing to do
    }
}
