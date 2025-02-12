//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {Errors} from "../../../libraries/Errors.sol";
import {IERC1643} from "../../../interfaces/engine/draft-IERC1643.sol";


/**
 * @title Document module
 * @dev 
 *
 * Retrieve documents from a documentEngine
 */

abstract contract DocumentModule is AuthorizationModule, IERC1643 {
    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event DocumentEngine(IERC1643 indexed newDocumentEngine);
   
    /* ============ ERC-7201 ============ */
    bytes32 public constant DOCUMENT_ROLE = keccak256("DOCUMENT_ROLE");
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DocumentModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DocumentModuleStorageLocation = 0x5edcb2767f407e647b6a4171ef53e8015a3eff0bb2b6e7765b1a26332bc43000;
    /* ==== ERC-7201 State Variables === */
    struct DocumentModuleStorage {
        IERC1643  _documentEngine;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __DocumentModule_init_unchained(IERC1643 documentEngine_)
    internal onlyInitializing {
        if (address(documentEngine_) != address (0)) {
            DocumentModuleStorage storage $ = _getDocumentModuleStorage();
            _setDocumentEngine($, documentEngine_);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function documentEngine() public view virtual returns (IERC1643) {
        DocumentModuleStorage storage $ = _getDocumentModuleStorage();
        return $._documentEngine;
    }

    function getDocument(string memory name) public view returns (Document memory document){
        DocumentModuleStorage storage $ = _getDocumentModuleStorage();
        if(address($._documentEngine) != address(0)){
            return $._documentEngine.getDocument(name);
        } else{
            return Document("", 0x0, 0);
        }
    }

    function getAllDocuments() public view returns (string[] memory documents){
        DocumentModuleStorage storage $ = _getDocumentModuleStorage();
        if(address($._documentEngine) != address(0)){
            documents =  $._documentEngine.getAllDocuments();
        }
    }

    /* ============  Restricted Functions ============ */
    /*
    * @notice set an authorizationEngine if not already set
    * 
    */
    function setDocumentEngine(
        IERC1643 documentEngine_
    ) external onlyRole(DOCUMENT_ROLE) {
        DocumentModuleStorage storage $ = _getDocumentModuleStorage();
        if ($._documentEngine == documentEngine_){
             revert Errors.CMTAT_DocumentModule_SameValue();
        }
        _setDocumentEngine($, documentEngine_);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setDocumentEngine(
        DocumentModuleStorage storage $, IERC1643 documentEngine_
    ) internal {
        $._documentEngine = documentEngine_;
        emit DocumentEngine(documentEngine_);
    }

    /* ============ ERC-7201 ============ */
    function _getDocumentModuleStorage() private pure returns (DocumentModuleStorage storage $) {
        assembly {
            $.slot := DocumentModuleStorageLocation
        }
    } 
}
