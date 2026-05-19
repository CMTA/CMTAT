
// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;
import {IDocumentEngine} from "../interfaces/engine/IDocumentEngine.sol";
interface IERC1643Whole is IDocumentEngine{

    /** 
    * @dev 
    * uri The URI of the document
    * documentHash The hash of the document contents
    * lastModified The timestamp of the last modification
    */ 
    struct DocumentInfo {
        bytes32 name;
        string uri;
        bytes32 documentHash;
    }
    // Document Management
    function setDocument(DocumentInfo calldata doc) external;
    function removeDocument(bytes32 name) external;

    // Document Events
    event DocumentRemoved(bytes32 indexed name, Document doc);
    event DocumentUpdated(bytes32 indexed name, Document doc);

}
/*
* @title a DocumentEngine mock for testing, not suitable for production
*/
contract DocumentEngineMock is IERC1643Whole {
    mapping(bytes32 => Document) private documents;
    mapping(bytes32 => uint256) private documentKey;
    bytes32[] private documentNames;

    /// @dev Error thrown when a document does not exist
    error DocumentDoesNotExist();

    /// @notice Retrieves the document details by name
    /// @param name The name of the document
    function getDocument(bytes32 name)
        external
        view
        override
        returns (Document memory doc)
    {
        return documents[name];
    }

    /// @notice Sets or updates a document
    /// @param doc_ the document
    function setDocument(DocumentInfo calldata doc_) external override {
        Document storage doc = documents[doc_.name];
        doc.uri = doc_.uri;
        doc.documentHash = doc_.documentHash;
        doc.lastModified = block.timestamp;
        if (documentKey[doc_.name] == 0) {
            // To avoid key == 0
            uint256 key = documentNames.length + 1;
            documentKey[doc_.name] = key;
            documentNames.push(doc_.name);
        }
        emit DocumentUpdated(doc_.name, doc);
    }

    /// @notice IERC1643-compatible setter
    function setDocument(
        bytes32 name,
        string calldata uri,
        bytes32 documentHash
    ) external override {
        Document storage doc = documents[name];
        doc.uri = uri;
        doc.documentHash = documentHash;
        doc.lastModified = block.timestamp;
        if (documentKey[name] == 0) {
            // To avoid key == 0
            uint256 key = documentNames.length + 1;
            documentKey[name] = key;
            documentNames.push(name);
        }
        emit DocumentUpdated(name, doc);
    }

    /// @notice Removes a document
    /// @param name The name of the document
    function removeDocument(bytes32 name) external override {
        if (documentKey[name] == 0) {
            revert DocumentDoesNotExist();
        }
        Document memory doc = documents[name];
        documentNames[documentKey[name] - 1] = documentNames[documentNames.length - 1];
        documentNames.pop();
        delete documents[name];
        documentKey[name] = 0;
        emit DocumentRemoved(name, doc);
    }

    /// @notice Retrieves all document names
    /// @return An array of document names
    function getAllDocuments() external view override returns (bytes32[] memory) {
        return documentNames;
    }
}
