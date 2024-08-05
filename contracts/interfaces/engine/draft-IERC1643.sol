//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/// @title IERC1643 Document Management 
/// (part of the ERC1400 Security Token Standards)
interface IERC1643 {
    // Document Management
    function getDocument(bytes32 _name) external view returns (string memory , bytes32, uint256);
    function getAllDocuments() external view returns (bytes32[] memory);
}