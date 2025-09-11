//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {CMTATBaseCommon} from "./0_CMTATBaseCommon.sol";
import {CMTATBaseERC2771, CMTATBaseERC20CrossChain} from "./4_CMTATBaseERC2771.sol";
import {ExtraInformationModule, ERC7551Module} from "./wrapper/options/ERC7551Module.sol";

/**
* @title Extend CMTAT Base Option with ERC7551Module
*/
abstract contract CMTATBaseERC7551 is CMTATBaseERC2771, ERC7551Module{
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control ==== */
    function  _authorizeExtraInfoManagement() internal virtual override(CMTATBaseCommon, ExtraInformationModule){
        CMTATBaseCommon._authorizeExtraInfoManagement();
    }
}
