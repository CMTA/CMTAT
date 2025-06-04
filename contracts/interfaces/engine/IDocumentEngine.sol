// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1643} from "../tokenization/draft-IERC1643.sol";
/*
* @dev minimum interface to define a DocumentEngine
*/
interface IDocumentEngine is IERC1643 {
   // nothing more
}

interface IDocumentEngineModule {
      /**
     * @dev Emitted when a rule engine is set.
     */
    event DocumentEngine(IERC1643 indexed newDocumentEngine);

   function setDocumentEngine(
        IERC1643 documentEngine_
    ) external;
    function documentEngine() external view;
}
