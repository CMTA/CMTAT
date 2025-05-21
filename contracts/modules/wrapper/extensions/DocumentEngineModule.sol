//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Engine === */
import {IERC1643, IDocumentEngine} from "../../../interfaces/engine/IDocumentEngine.sol";

/**
 * @title Document module
 * @dev 
 *
 * Retrieve documents from a documentEngine
 */

abstract contract DocumentEngineModule is AuthorizationModule, IERC1643 {
    error CMTAT_DocumentEngineModule_SameValue();

    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event DocumentEngine(IERC1643 indexed newDocumentEngine);
   
    /* ============ ERC-7201 ============ */
    bytes32 public constant DOCUMENT_ROLE = keccak256("DOCUMENT_ROLE");
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DocumentEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DocumentEngineModuleStorageLocation = 0xbd0905600c85d707dc53eba2e146c1c2527cd32ac3ff6b86846155151b3e2700;
    /* ==== ERC-7201 State Variables === */
    struct DocumentEngineModuleStorage {
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
    function __DocumentEngineModule_init_unchained(IERC1643 documentEngine_)
    internal onlyInitializing {
        if (address(documentEngine_) != address (0)) {
            DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
            _setDocumentEngine($, documentEngine_);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function documentEngine() public view virtual returns (IERC1643) {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        return $._documentEngine;
    }

    function getDocument(string memory name) public view  virtual returns (Document memory document){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            return $._documentEngine.getDocument(name);
        } else{
            return Document("", 0x0, 0);
        }
    }

    function getAllDocuments() public view virtual returns (string[] memory documents){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
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
    ) external virtual onlyRole(DOCUMENT_ROLE) {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        require($._documentEngine != documentEngine_, CMTAT_DocumentEngineModule_SameValue());
        _setDocumentEngine($, documentEngine_);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setDocumentEngine(
        DocumentEngineModuleStorage storage $, IERC1643 documentEngine_
    ) internal virtual {
        $._documentEngine = documentEngine_;
        emit DocumentEngine(documentEngine_);
    }

    /* ============ ERC-7201 ============ */
    function _getDocumentEngineModuleStorage() private pure returns (DocumentEngineModuleStorage storage $) {
        assembly {
            $.slot := DocumentEngineModuleStorageLocation
        }
    } 
}
