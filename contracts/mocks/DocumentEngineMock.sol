// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import {DocumentERC1643Module} from "../modules/wrapper/extensions/DocumentERC1643Module.sol";

/*
* @title a DocumentEngine mock for testing, not suitable for production
* @dev Reuses the in-contract ERC-1643 module {DocumentERC1643Module} so the engine
* shares the exact storage layout, O(1) swap-pop enumeration (with the moved-name key
* update), standard events (`DocumentUpdated`/`DocumentRemoved` with the flat
* `(string uri, bytes32 documentHash)` signature) and typed errors
* (`ERC1643InvalidName`/`ERC1643MissingDocument`) of the production module.
* @dev Access control is intentionally a no-op: in the engine-delegation flow the CMTAT
* token already enforces `DOCUMENT_ENGINE_ROLE` before forwarding to the engine, and
* tests may also call the engine directly.
*/
contract DocumentEngineMock is DocumentERC1643Module {
    function _authorizeDocumentManagement() internal virtual override {}
}
