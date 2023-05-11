//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "./modules/CMTAT_BASE.sol";

contract CMTAT_PROXY is CMTAT_BASE {
    /** 
    @notice Contract version for the deployment with a proxy
    @param forwarderIrrevocable address of the forwarder, required for the gasless support
    */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) MetaTxModule(forwarderIrrevocable) {
        // Initialize the variable for the implementation
        deployedWithProxy = true;
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }

    uint256[50] private __gap;
}
