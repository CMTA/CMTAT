// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
/* ==== Module === */
import {CMTATBaseAccessControl} from "./2_CMTATBaseAccessControl.sol";
import {CMTATBaseERC7551Enforcement} from "./7_CMTATBaseERC7551Enforcement.sol";
import {ExtraInformationModule, ERC7551Module} from "./wrapper/options/ERC7551Module.sol";

/**
* @title Extend CMTAT Base with ERC7551Module and ERC20EnforcementERC7551Module
*/
abstract contract CMTATBaseERC7551 is CMTATBaseERC7551Enforcement, ERC7551Module {
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control ==== */
    function _authorizeExtraInfoManagement() internal virtual override(CMTATBaseAccessControl, ExtraInformationModule) {
        CMTATBaseAccessControl._authorizeExtraInfoManagement();
    }
}
