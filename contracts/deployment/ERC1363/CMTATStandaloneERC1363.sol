//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseERC1363} from "../../modules/6_CMTATBaseERC1363.sol";
import {ERC2771Module, ERC2771ContextUpgradeable} from "../../modules/wrapper/options/ERC2771Module.sol";
import {ICMTATConstructor} from "../../interfaces/technical/ICMTATConstructor.sol";


/**
* @title CMTAT standalone version for ERC1363
*/
contract CMTATStandaloneERC1363 is CMTATBaseERC1363 {
    /**
     * @notice Contract version for standalone deployment
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param extraInformationAttributes_ tokenId, terms, information
     * @param engines_ external contract
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_ 
    ) ERC2771Module(forwarderIrrevocable) {
        // Initialize the contract to avoid front-running
        initialize(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_
        );
    }
}
