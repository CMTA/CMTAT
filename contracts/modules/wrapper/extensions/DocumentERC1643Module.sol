// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC1643} from "../../../interfaces/tokenization/draft-IERC1643.sol";

/**
 * @title DocumentERC1643 module
 * @dev In-contract ERC-1643 document management.
 */
abstract contract DocumentERC1643Module is Initializable, IERC1643 {
    bytes32 public constant DOCUMENT_ROLE = keccak256("DOCUMENT_ROLE");
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DocumentERC1643Module")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DocumentERC1643ModuleStorageLocation = 0x24fbb1cf6345ced60d5278ef6f68f4f7576fd9068704b4c8f1eec8f0bbd8a200;

    struct DocumentERC1643ModuleStorage {
        mapping(bytes32 => Document) _documents;
        mapping(bytes32 => uint256) _documentKey;
        bytes32[] _documentNames;
    }

    modifier onlyDocumentManager() {
        _authorizeDocumentManagement();
        _;
    }

    function getDocument(bytes32 name) public view virtual override returns (Document memory document) {
        return _getDocumentERC1643ModuleStorage()._documents[name];
    }

    function getAllDocuments() public view virtual override returns (bytes32[] memory documentNames_) {
        return _getDocumentERC1643ModuleStorage()._documentNames;
    }

    function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) public virtual override onlyDocumentManager {
        DocumentERC1643ModuleStorage storage $ = _getDocumentERC1643ModuleStorage();
        Document storage document = $._documents[name];
        document.uri = uri;
        document.documentHash = documentHash;
        document.lastModified = block.timestamp;

        if ($._documentKey[name] == 0) {
            $._documentNames.push(name);
            $._documentKey[name] = $._documentNames.length;
        }

        emit DocumentUpdated(name, uri, documentHash);
    }

    function removeDocument(bytes32 name) public virtual override onlyDocumentManager {
        DocumentERC1643ModuleStorage storage $ = _getDocumentERC1643ModuleStorage();
        uint256 key = $._documentKey[name];
        require(key != 0, ERC1643MissingDocument());

        Document memory document = $._documents[name];
        uint256 index = key - 1;
        uint256 lastIndex = $._documentNames.length - 1;

        if (index != lastIndex) {
            bytes32 movedName = $._documentNames[lastIndex];
            $._documentNames[index] = movedName;
            $._documentKey[movedName] = key;
        }

        $._documentNames.pop();
        delete $._documents[name];
        delete $._documentKey[name];

        emit DocumentRemoved(name, document.uri, document.documentHash);
    }

    function _authorizeDocumentManagement() internal virtual;

    function _getDocumentERC1643ModuleStorage() private pure returns (DocumentERC1643ModuleStorage storage $) {
        assembly {
            $.slot := DocumentERC1643ModuleStorageLocation
        }
    }
}
