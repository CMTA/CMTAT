// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {CMTATBaseAccessControl} from "./1_CMTATBaseAccessControl.sol";
import {CMTATBaseERC2771} from "./5_CMTATBaseERC2771.sol";
import {ExtraInformationModule, ERC7551Module} from "./wrapper/options/ERC7551Module.sol";

/**
* @title Extend CMTAT Base with ERC7551Module
*/
abstract contract CMTATBaseERC7551 is CMTATBaseERC2771, ERC7551Module{
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control ==== */
    function  _authorizeExtraInfoManagement() internal virtual override(CMTATBaseAccessControl, ExtraInformationModule){
        CMTATBaseAccessControl._authorizeExtraInfoManagement();
    }
}
