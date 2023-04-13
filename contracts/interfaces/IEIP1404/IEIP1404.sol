//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;

/*
@dev Contrary to the EIP-1404, this interface does not inherit from the ERC20 interface
*/
interface IEIP1404 {
    /**
     * @dev See ERC/EIP-1404
     *
     */
    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (uint8);

    /**
     * @dev See ERC/EIP-1404
     *
     */
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external view returns (string memory);
}
