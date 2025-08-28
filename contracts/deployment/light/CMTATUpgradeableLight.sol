//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseCore} from "../../modules/0_CMTATBaseCore.sol";


/**
* @title CMTAT version for a proxy light deployment (Transparent or Beacon proxy)
*/
contract CMTATUpgradeableLight is CMTATBaseCore {
    /**
     * @notice Contract version for the deployment with a proxy
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor()  {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }
}
