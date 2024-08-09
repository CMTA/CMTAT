//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "./CMTATFactoryRoot.sol";

/**
* @notice Code common to TP and UUPS Factory
* 
*/
abstract contract CMTATFactoryBase is CMTATFactoryRoot {
    // Public
    address public immutable logic;
    /**
    * @param logic_ contract implementation
    * @param factoryAdmin admin
    */
    constructor(address logic_, address factoryAdmin, bool useCustomSalt_)CMTATFactoryRoot( factoryAdmin, useCustomSalt_) {
        if(logic_ == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForLogicContract();
        }
        logic = logic_;
    }
}