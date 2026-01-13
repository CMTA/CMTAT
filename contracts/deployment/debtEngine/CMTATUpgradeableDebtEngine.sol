//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseDebtEngine} from "../../modules/5_CMTATBaseDebtEngine.sol";
/**
* @title CMTAT version for a proxy deployment (Transparent or Beacon proxy)
*/
contract CMTATUpgradeableDebtEngine is CMTATBaseDebtEngine {
    /**
     * @notice Contract version for the deployment with a proxy
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }
}
