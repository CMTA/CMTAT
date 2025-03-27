//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @dev Contrary to the ERC-1404, this interface does not inherit from the ERC20 interface
*/
interface IERC1404 {
    /* 
    * @dev leave the code 4-9 free/unused for further additions in your ruleEngine implementation
    */
    enum REJECTED_CODE_BASE {
        TRANSFER_OK,
        TRANSFER_REJECTED_PAUSED,
        TRANSFER_REJECTED_FROM_FROZEN,
        TRANSFER_REJECTED_TO_FROZEN
    }
    /**
     * @dev See ERC-1404
     *
     */
    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (uint8);

    /**
     * @dev See ERC-1404
     *
     */
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external view returns (string memory);
}
