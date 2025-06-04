//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @title IERC1643 Document Management 
* @dev Part of the ERC1400 Security Token Standards
* Contrary to the original specification, use a struct Document to represent a Document
*/
interface IERC1643 {
    struct Document {
        string uri;
        bytes32 documentHash;
        // last on-chain modification date (generally set by the smart contract)
        uint256 lastModified;
    }

    // Document Management
    /**
     * @notice return a document identified by its name
     */
    function getDocument(string memory name) external view returns (Document memory doc);
    /**
     * @notice return all documents
     */
    function getAllDocuments() external view returns (string[] memory);
}