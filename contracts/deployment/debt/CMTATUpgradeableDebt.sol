//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseDebt} from "../../modules/2_CMTATBaseDebt.sol";
/**
* @title CMTAT version for a proxy deployment (Transparent or Beacon proxy)
*/
contract CMTATUpgradeableDebt is CMTATBaseDebt {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }
}
