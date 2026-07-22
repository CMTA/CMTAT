// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin=== */
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
/* ==== Engine === */
import {IERC1643} from "../../../interfaces/engine/IDocumentEngine.sol";
import {IDocumentEngineModule} from "../../../interfaces/modules/IDocumentEngineModule.sol";

/**
 * @title Document module (ERC1643)
 * @dev 
 *
 * Retrieve documents from a documentEngine (external contract)
 */
abstract contract DocumentEngineModule is Initializable, IDocumentEngineModule {
    /* ============ ERC-7201 ============ */
    bytes32 public constant DOCUMENT_ENGINE_ROLE = keccak256("DOCUMENT_ENGINE_ROLE");
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DocumentEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DocumentEngineModuleStorageLocation = 0xbd0905600c85d707dc53eba2e146c1c2527cd32ac3ff6b86846155151b3e2700;
    /* ==== ERC-7201 State Variables === */
    struct DocumentEngineModuleStorage {
        IERC1643  _documentEngine;
    }

    /* ============ Modifier ============ */
    modifier onlyDocumentManager() {
        _authorizeDocumentManagement();
        _;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - set a DocumentEngine if address different from zero
     * Warning: not used in the different deployment version to reduce contract code size and simplify code
     * If not used, the function will not be included in the final bytecode if compiled with the optimizer enabled
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
    function getDocument(bytes32 name) public view  virtual override(IERC1643) returns (string memory uri, bytes32 documentHash, uint256 lastModified){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            return $._documentEngine.getDocument(name);
        } else{
            return ("", 0x0, 0);
        }
    }

    /**
    * @inheritdoc IERC1643
    */
    function getAllDocuments() public view virtual override(IERC1643) returns (bytes32[] memory documentNames_){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            documentNames_ =  $._documentEngine.getAllDocuments();
        }
    }

    function setDocument(bytes32 name, string calldata uri, bytes32 documentHash) public virtual override(IERC1643) onlyDocumentManager {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        require(address($._documentEngine) != address(0), CMTAT_DocumentEngineModule_NoDocumentEngine());
        // Persist in the engine (which reverts on invalid input, e.g. the zero name), then re-emit
        // the standard ERC-1643 event on the token's own address. ERC-1643 is a per-contract
        // interface and integrators subscribe to the token that exposes {setDocument}; without this
        // re-emission the update would only be observable on the engine's address. The engine also
        // emits, on its own address.
        $._documentEngine.setDocument(name, uri, documentHash);
        emit DocumentUpdated(name, uri, documentHash);
    }

    function removeDocument(bytes32 name) public virtual override(IERC1643) onlyDocumentManager {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        require(address($._documentEngine) != address(0), CMTAT_DocumentEngineModule_NoDocumentEngine());
        // Read the metadata before removal so the token can re-emit DocumentRemoved with the removed
        // values (spec: "MUST emit DocumentRemoved with the removed metadata"). The forwarded
        // removeDocument reverts if the document is missing, so the token only emits after a genuine
        // removal.
        (string memory uri, bytes32 documentHash, ) = $._documentEngine.getDocument(name);
        $._documentEngine.removeDocument(name);
        emit DocumentRemoved(name, uri, documentHash);
    }

    /* ============  Restricted Functions ============ */

    /**
    * @inheritdoc IDocumentEngineModule
    */
    function setDocumentEngine(
        IERC1643 documentEngine_
    ) public virtual override(IDocumentEngineModule) onlyDocumentManager {
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        require(address($._documentEngine) != address(documentEngine_), CMTAT_DocumentEngineModule_SameValue());
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

    /* ============ Access Control ============ */
    function  _authorizeDocumentManagement() internal virtual;

    /* ============ ERC-7201 ============ */
    function _getDocumentEngineModuleStorage() private pure returns (DocumentEngineModuleStorage storage $) {
        assembly {
            $.slot := DocumentEngineModuleStorageLocation
        }
    } 
}
