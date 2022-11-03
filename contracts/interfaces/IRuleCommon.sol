//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;


interface IRuleCommon {
    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool isValid);
}