//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/// @title IERC1643 Document Management 
/// (part of the ERC1400 Security Token Standards)
interface IERC1643 {
    struct Document {
        string uri;
        bytes32 documentHash;
        uint256 lastModified;
    }

    // Document Management
    function getDocument(string memory name) external view returns (Document memory doc);
    function getAllDocuments() external view returns (string[] memory);
}