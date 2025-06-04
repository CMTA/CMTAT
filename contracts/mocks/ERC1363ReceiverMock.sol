//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract ERC1363ReceiverMock is IERC1363Receiver {
    event TokensReceived(address indexed operator, address indexed from, uint256 value, bytes data);

    function onTransferReceived(address operator, address from, uint256 value, bytes calldata data) external override returns (bytes4) {
        emit TokensReceived(operator, from, value, data);
        return IERC1363Receiver.onTransferReceived.selector;
    }
}