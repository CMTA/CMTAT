//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "./CMTAT_BASE_SnapshotTest.sol";

contract CMTATSnapshotProxyTest is CMTAT_BASE_SnapshotTest {
    /** 
    @notice Contract version for the deployment with a proxy
    @param forwarderIrrevocable address of the forwarder, required for the gasless support
    */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) MetaTxModule(forwarderIrrevocable) {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }

    uint256[50] private __gap;
}
