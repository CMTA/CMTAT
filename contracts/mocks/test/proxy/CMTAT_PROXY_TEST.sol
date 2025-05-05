//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATUpgradeable} from "../../../deployment/CMTATUpgradeable.sol";


/**
 * @title a contrat used to test the proxy upgrade functionality
 */
contract CMTAT_PROXY_TEST is CMTATUpgradeable {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) CMTATUpgradeable(forwarderIrrevocable) {
        // Nothing to do
    }
}
