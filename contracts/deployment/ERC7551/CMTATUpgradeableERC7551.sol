//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ERC2771Module} from "../../modules/wrapper/options/ERC2771Module.sol";
import {CMTATBaseERC7551} from "../../modules/5_CMTATBaseERC7551.sol";

/**
* @title CMTAT version for a proxy deployment (Transparent or Beacon proxy)
*/
contract CMTATUpgradeableERC7551 is CMTATBaseERC7551 {
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
