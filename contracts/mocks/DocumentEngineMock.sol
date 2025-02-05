
// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;
import {IERC1643} from "../interfaces/engine/draft-IERC1643.sol";
interface IERC1643Whole is IERC1643{
    /// uri The URI of the document
    /// @return documentHash The hash of the document contents
    /// @return lastModified The timestamp of the last modification
    struct DocumentInfo {
        string name;
        string uri;
        bytes32 documentHash;
    }
    // Document Management
    function setDocument(DocumentInfo calldata doc) external;
    function removeDocument(string memory name) external;

    // Document Events
    event DocumentRemoved(string indexed name, Document doc);
    event DocumentUpdated(string indexed name, Document doc);

}
/*
* @title a DocumentEngine mock for testing, not suitable for production
*/
contract DocumentEngineMock is IERC1643Whole {
    /*struct DocumentStorage {
        uint256 key;
        Document doc;
    }*/
    mapping(string => Document) private documents;
    mapping(string => uint256) private documentKey;
    string[] private documentNames;

    /// @dev Error thrown when a document does not exist
    error DocumentDoesNotExist();

    /// @notice Retrieves the document details by name
    /// @param name The name of the document
    function getDocument(string memory name)
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

    /// @notice Removes a document
    /// @param name The name of the document
    function removeDocument(string calldata name) external override {
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
    function getAllDocuments() external view override returns (string[] memory) {
        return documentNames;
    }
}