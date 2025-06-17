//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseERC7551} from "../../modules/5_CMTATBaseERC7551.sol";
import {ICMTATConstructor} from "../../modules/2_CMTATBase.sol";
import {MetaTxModule} from "../../modules/wrapper/options/MetaTxModule.sol";

/**
* @title CMTAT version for a standalone deployment (without proxy)
*/
contract CMTATStandaloneERC7551 is CMTATBaseERC7551 {
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
    ) MetaTxModule(forwarderIrrevocable) {
        // Initialize the contract to avoid front-running
        // Warning : do not initialize the proxy
        initialize(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_
        );
    }





}
