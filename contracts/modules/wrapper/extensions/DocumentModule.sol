//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../security/AuthorizationModule.sol";
import "../../../libraries/Errors.sol";
import "../../../interfaces/draft-IERC1643.sol";
abstract contract DocumentModule is AuthorizationModule, IERC1643 {
    bytes32 public constant DOCUMENT_ROLE = keccak256("DOCUMENT_ROLE");
    IERC1643 public documentEngine;
    /**
     * @dev Emitted when a rule engine is set.
     */
    event DocumentEngine(IERC1643 indexed newDocumentEngine);
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
            documentEngine = documentEngine_;
            emit DocumentEngine(documentEngine_);
        }
    }

    /*
    * @notice set an authorizationEngine if not already set
    * 
    */
    function setDocumentEngine(
        IERC1643 documentEngine_
    ) external onlyRole(DOCUMENT_ROLE) {
        documentEngine = documentEngine_;
        emit DocumentEngine(documentEngine_);
    }


    function getDocument(bytes32 _name) public view returns (string memory, bytes32, uint256){
        if(address(documentEngine) != address(0)){
            return documentEngine.getDocument( _name);
        } else{
            return ("",0x0, 0);
        }
    }

    function getAllDocuments() public view returns (bytes32[] memory documents){
        if(address(documentEngine) != address(0)){
            documents =  documentEngine.getAllDocuments();
        }
    }


    uint256[50] private __gap;
}
