//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseAllowlist, ISnapshotEngine, IERC1643} from "../../modules/CMTATBaseAllowlist.sol";
import {ICMTATConstructor} from "../../modules/CMTATBase.sol";

/**
* @title CMTAT version for a standalone deployment (without proxy)
*/
contract CMTATStandaloneAllowlist is CMTATBaseAllowlist {
    /**
     * @notice Contract version for standalone deployment
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param baseModuleAttributes_ tokenId, terms, information
     * @param engines_ external contract
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_,
        ISnapshotEngine snapshotEngine,
        IERC1643 documentEngine
        
    ) {
        // Initialize the contract to avoid front-running
        // Warning : do not initialize the proxy
        initialize(
            admin,
            ERC20Attributes_,
            baseModuleAttributes_,
            snapshotEngine,
            documentEngine
        );
    }
}
