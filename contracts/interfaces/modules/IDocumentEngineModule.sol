// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1643} from "../tokenization/draft-IERC1643.sol";
/*
* @dev minimum interface to define a DocumentEngineModule
*/
interface IDocumentEngineModule is IERC1643 {
   /* ============ Events ============ */
   /**
   * @dev Emitted when a rule engine is set.
   */
   event DocumentEngine(IERC1643 indexed newDocumentEngine);
   /* ============ Error ============ */
   error CMTAT_DocumentEngineModule_SameValue();
   /* ============ Functions ============ */
   /*
    * @notice set a documentEngine
    * 
    */
   function setDocumentEngine(
        IERC1643 documentEngine_
    ) external;
    /**
    * @notice return document engine address
    */
    function documentEngine() external view returns (IERC1643);
}
