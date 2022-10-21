//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

interface IRule {
    function isTransferValid(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool isValid);

    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (uint256);

    function canReturnTransferRestrictionCode(uint256 _restrictionCode)
        external
        view
        returns (bool);

    function messageForTransferRestriction(uint256 _restrictionCode)
        external
        view
        returns (string memory);
}
