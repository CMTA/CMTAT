//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

import {CMTATStandardUpgradeable} from "../../../deployment/CMTATStandardUpgradeable.sol";


/**
 * @title a contrat used to test the proxy upgrade functionality
 */
contract CMTAT_PROXY_TEST is CMTATStandardUpgradeable {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) CMTATStandardUpgradeable(forwarderIrrevocable) {
        // Nothing to do
    }
}
