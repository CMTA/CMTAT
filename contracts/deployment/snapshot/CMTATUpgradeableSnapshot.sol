//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseERC2771Snapshot} from "../../modules/7_CMTATBaseERC2771Snapshot.sol";
import {ERC2771Module} from "../../modules/wrapper/options/ERC2771Module.sol";


/**
* @title CMTAT with snapshot engine — proxy deployment (Transparent or Beacon proxy)
*/
contract CMTATUpgradeableSnapshot is CMTATBaseERC2771Snapshot {
    /**
     * @notice Contract version for the deployment with a proxy, with snapshot engine
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
