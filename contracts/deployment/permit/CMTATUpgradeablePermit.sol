//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseERC2612} from "../../modules/6_CMTATBaseERC2612.sol";

/**
* @title CMTAT version for a proxy deployment (Transparent or Beacon proxy) with Permit and Multicall
*/
contract CMTATUpgradeablePermit is CMTATBaseERC2612 {
    /**
     * @notice Contract version for the deployment with a proxy
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }
}
