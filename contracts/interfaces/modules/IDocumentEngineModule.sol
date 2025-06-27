// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1643} from "../tokenization/draft-IERC1643.sol";

/**
* @title IDocumentEngineModule
* @notice Interface for modules that delegate document management to an external document engine.
* @dev This interface extends IERC1643 to support standard document handling.
*/
interface IDocumentEngineModule is IERC1643 {
   /* ============ Events ============ */
    /**
    * @notice Emitted when a new document engine is set.
    * @dev Indicates that the module now delegates document logic to a new external contract.
    * @param newDocumentEngine The address of the newly assigned document engine.
    */
   event DocumentEngine(IERC1643 indexed newDocumentEngine);
   /* ============ Error ============ */
    /**
    * @notice Thrown when attempting to set the same document engine as the current one.
    */
   error CMTAT_DocumentEngineModule_SameValue();
   /* ============ Functions ============ */
    /**
    * @notice Sets a new document engine contract.
    * @dev Only changes the engine if the new address is different from the current one.
    * Throws {CMTAT_DocumentEngineModule_SameValue} if the same engine is provided.
    * @param documentEngine_ The address of the new IERC1643-compliant document engine.
    */
   function setDocumentEngine(
        IERC1643 documentEngine_
    ) external;

    /**
     * @notice Returns the address of the current document engine.
     * @return documentEngine_ The IERC1643 document engine currently in use.
     */
    function documentEngine() external view returns (IERC1643 documentEngine_);
}
