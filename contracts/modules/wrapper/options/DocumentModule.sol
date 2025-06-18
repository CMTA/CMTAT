//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {DocumentEngineModule} from "../extensions/DocumentEngineModule.sol";
/* ==== Engine === */
import {IERC1643, IDocumentEngine} from "../../../interfaces/engine/IDocumentEngine.sol";
import {IDocumentEngineModule} from "../../../interfaces/modules/IDocumentEngineModule.sol";

/**
 * @title Document module (ERC1643)
 * @dev 
 *
 * Retrieve documents from a documentEngine
 */

abstract contract DocumentModule is DocumentEngineModule {
    event DocumentRemoved(string indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(string indexed _name, string _uri, bytes32 _documentHash);

        /**
     * @notice Restricted function to set or update a document
     */
    function setDocument(
        string memory name_,
        string memory uri_,
        bytes32 documentHash_
    ) public onlyRole(DOCUMENT_ROLE) {
        _setDocument(name_, uri_, documentHash_);
    }

    /**
     * @notice Restricted function to remove a document for a given smart contract and name
     */
    function removeDocument(
        string memory name_
    ) external onlyRole(DOCUMENT_ROLE) {
        _removeDocument(name_);
    }

    function getDocument(string memory name) public view  virtual override(DocumentEngineModule) returns (Document memory document){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            return $._documentEngine.getDocument(name);
        } else{
            return $._documents[name] ;
        }
    }

    function getAllDocuments() public view virtual override(DocumentEngineModule) returns (string[] memory documents){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            documents =  $._documentEngine.getAllDocuments();
        } else {
            return $._documentNames;
        }
    }

    function _removeDocument(string memory name_) internal {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        Document memory doc = $._documents[name_];
        emit DocumentRemoved(name_, doc.uri, doc.documentHash);

        delete $._documents[name_];
        _removeDocumentName(name_);
    }

    function _setDocument(
        string memory name_,
        string memory uri_,
        bytes32 documentHash_
    ) internal {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        Document storage doc = $._documents[name_];
        if (doc.lastModified == 0) {
            // new document
            $._documentNames.push(name_);
        }
        doc.uri = uri_;
        doc.documentHash = documentHash_;
        doc.lastModified = block.timestamp;
        emit DocumentUpdated(name_, uri_, documentHash_);
    }

    /**
     * @dev Internal helper to remove the document name from the list of document names
     */
    function _removeDocumentName(
        string memory name_
    ) internal {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        uint256 length = $._documentNames.length;
        for (uint256 i = 0; i < length; ++i) {
            if (keccak256(bytes($._documentNames[i])) == keccak256(bytes(name_))) {
                $._documentNames[i] = $._documentNames[length - 1];
                $._documentNames.pop();
                break;
            }
        }
    }
}
