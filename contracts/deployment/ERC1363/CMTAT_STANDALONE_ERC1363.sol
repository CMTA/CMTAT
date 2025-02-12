//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTAT_ERC1363_BASE} from "../../modules/CMTAT_ERC1363_BASE.sol";
import {CMTAT_BASE, MetaTxModule, ICMTATConstructor} from "../../modules/CMTAT_BASE.sol";
/**
* @title CMTAT standalone version for ERC1363
*/
contract CMTAT_STANDALONE_ERC1363 is CMTAT_ERC1363_BASE {
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
        address forwarderIrrevocable,
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) MetaTxModule(forwarderIrrevocable) {
        // Initialize the contract to avoid front-running
        // Warning : do not initialize the proxy
        initialize(
            admin,
            ERC20Attributes_,
            baseModuleAttributes_,
            engines_
        );
    }
}
