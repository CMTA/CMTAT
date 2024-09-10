
// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;
import "../interfaces/engine/draft-IERC1643.sol";
interface IERC1643Whole is IERC1643{

    // Document Management
    function setDocument(bytes32 _name, string memory _uri, bytes32 _documentHash) external;
    function removeDocument(bytes32 _name) external;

    // Document Events
    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);

}
/*
* @title a DocumentEngine mock for testing, not suitable for production
*/
contract DocumentEngineMock is IERC1643Whole {
     struct Document {
        string uri;
        bytes32 documentHash;
        uint256 lastModified;
    }

    mapping(bytes32 => Document) private documents;
    bytes32[] private documentNames;

    /// @dev Error thrown when a document does not exist
    error DocumentDoesNotExist();

    /// @notice Retrieves the document details by name
    /// @param name_ The name of the document
    /// @return uri The URI of the document
    /// @return documentHash The hash of the document contents
    /// @return lastModified The timestamp of the last modification
    function getDocument(bytes32 name_)
        external
        view
        override
        returns (string memory uri, bytes32 documentHash, uint256 lastModified)
    {
        if (bytes(documents[name_].uri).length == 0) {
            return("", 0x0, 0);
        }

        Document storage doc = documents[name_];
        return (doc.uri, doc.documentHash, doc.lastModified);
    }

    /// @notice Sets or updates a document
    /// @param name_ The name of the document
    /// @param uri_ The URI of the document
    /// @param documentHash_ The hash of the document contents
    function setDocument(bytes32 name_, string memory uri_, bytes32 documentHash_) external override {
        Document storage doc = documents[name_];
        bool isUpdate = bytes(doc.uri).length != 0;

        doc.uri = uri_;
        doc.documentHash = documentHash_;
        doc.lastModified = block.timestamp;

        if (!isUpdate) {
            documentNames.push(name_);
        }

        emit DocumentUpdated(name_, uri_, documentHash_);
    }

    /// @notice Removes a document
    /// @param name_ The name of the document
    function removeDocument(bytes32 name_) external override {
        if (bytes(documents[name_].uri).length == 0) {
            revert DocumentDoesNotExist();
        }

        Document memory doc = documents[name_];
        delete documents[name_];

        for (uint256 i = 0; i < documentNames.length; i++) {
            if (documentNames[i] == name_) {
                documentNames[i] = documentNames[documentNames.length - 1];
                documentNames.pop();
                break;
            }
        }

        emit DocumentRemoved(name_, doc.uri, doc.documentHash);
    }

    /// @notice Retrieves all document names
    /// @return An array of document names
    function getAllDocuments() external view override returns (bytes32[] memory) {
        return documentNames;
    }
}