//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

interface IERC1404EnumCode {
    /* 
    * @dev leave the code 4-9 free/unused for further additions in your ruleEngine implementation
    */
    enum REJECTED_CODE_BASE {
        TRANSFER_OK,
        TRANSFER_REJECTED_PAUSED,
        TRANSFER_REJECTED_FROM_FROZEN,
        TRANSFER_REJECTED_TO_FROZEN
    }
}
