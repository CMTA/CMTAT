//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;

import "./IEIP1404.sol";

interface IEIP1404Wrapper is IEIP1404 {
    /* 
    @dev leave the code 4-9 free/unused for further additions in your ruleEngine implementation
    */
    enum REJECTED_CODE_BASE {
        TRANSFER_OK,
        TRANSFER_REJECTED_PAUSED,
        TRANSFER_REJECTED_FROM_FROZEN,
        TRANSFER_REJECTED_TO_FROZEN
    }
    
    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool isValid);
}
