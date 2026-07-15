// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @title IERC1643 Document Management 
* @dev Part of the ERC1400 Security Token Standards
* Contrary to the original specification, use a struct Document to represent a Document
*/
interface IERC1643 {
    /// @dev Reverted when removing a document whose name is not registered.
    error ERC1643MissingDocument();
    /// @dev Reverted when setting a document with the zero name.
    error ERC1643InvalidName();

     /// @dev Struct used to represent a document and its metadata.
    struct Document {
         // URI of the off-chain document (e.g., IPFS, HTTPS)
        string uri;  
         // Hash of the document content
        bytes32 documentHash; 
         // Timestamp of the last on-chain modification (set by the smart contract)
        uint256 lastModified;
    }

    // Document Management
    /**
     * @notice Retrieves a document by its registered name.
     * @param name The unique name used to identify the document.
     * @return document The associated document's metadata (URI, hash, timestamp).
     */
    function getDocument(bytes32 name) external view returns (Document memory document);
    /**
     * @notice Returns the list of all document names registered in the contract.
     * @return documentNames_ An array of strings representing all document identifiers.
     */
    function getAllDocuments() external view returns (bytes32[] memory documentNames_);

    function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) external;

    function removeDocument(bytes32 name) external;

    event DocumentUpdated(bytes32 indexed name, string uri, bytes32 documentHash);

    event DocumentRemoved(bytes32 indexed name, string uri, bytes32 documentHash);
}
