//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;


interface IERC1404 {
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
    function messageForTransferRestriction(uint8 _restrictionCode)
        external
        view
        returns (string memory);
}