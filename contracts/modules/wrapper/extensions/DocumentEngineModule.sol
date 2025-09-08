//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin=== */
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
/* ==== Engine === */
import {IERC1643, IDocumentEngine} from "../../../interfaces/engine/IDocumentEngine.sol";
import {IDocumentEngineModule} from "../../../interfaces/modules/IDocumentEngineModule.sol";

/**
 * @title Document module (ERC1643)
 * @dev 
 *
 * Retrieve documents from a documentEngine
 */

abstract contract DocumentEngineModule is Initializable, IDocumentEngineModule {
    /* ============ ERC-7201 ============ */
    bytes32 public constant DOCUMENT_ROLE = keccak256("DOCUMENT_ROLE");
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DocumentEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DocumentEngineModuleStorageLocation = 0xbd0905600c85d707dc53eba2e146c1c2527cd32ac3ff6b86846155151b3e2700;
    /* ==== ERC-7201 State Variables === */
    struct DocumentEngineModuleStorage {
        IERC1643  _documentEngine;
    }

    modifier onlyDocumentManager() {
        _authorizeDocumentManagement();
        _;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - set a DocumentEngine if address different from zero
     *
     */
    function __DocumentEngineModule_init_unchained(IERC1643 documentEngine_)
    internal virtual onlyInitializing {
        if (address(documentEngine_) != address (0)) {
            DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
            _setDocumentEngine($, documentEngine_);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc IDocumentEngineModule
    */
    function documentEngine() public view virtual override(IDocumentEngineModule) returns (IERC1643 documentEngine_) {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        return $._documentEngine;
    }

    /**
    * @inheritdoc IERC1643
    */
    function getDocument(string memory name) public view  virtual override(IERC1643) returns (Document memory document){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            return $._documentEngine.getDocument(name);
        } else{
            return Document("", 0x0, 0);
        }
    }

    /**
    * @inheritdoc IERC1643
    */
    function getAllDocuments() public view virtual override(IERC1643) returns (string[] memory documentNames_){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            documentNames_ =  $._documentEngine.getAllDocuments();
        }
    }

    /* ============  Restricted Functions ============ */

    /**
    * @inheritdoc IDocumentEngineModule
    */
    function setDocumentEngine(
        IERC1643 documentEngine_
    ) public virtual override(IDocumentEngineModule) onlyDocumentManager {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        require($._documentEngine != documentEngine_, CMTAT_DocumentEngineModule_SameValue());
        _setDocumentEngine($, documentEngine_);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function  _authorizeDocumentManagement() internal virtual;
   
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
