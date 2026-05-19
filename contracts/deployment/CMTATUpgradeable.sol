//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseERC7551Enforcement} from "../modules/7_CMTATBaseERC7551Enforcement.sol";
import {ERC2771Module} from "../modules/wrapper/options/ERC2771Module.sol";


/**
* @title CMTAT standard version for a proxy deployment (Transparent or Beacon proxy) — no snapshot engine
*/
contract CMTATStandardUpgradeable is CMTATBaseERC7551Enforcement {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) ERC2771Module(forwarderIrrevocable) {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }
}
