// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseCore} from "../../modules/0_CMTATBaseCore.sol";
import {DocumentEngineModule} from "../../modules/wrapper/options/DocumentEngineModule.sol";
import {ICMTATConstructor} from "../../interfaces/technical/ICMTATConstructor.sol";
import {IERC1643} from "../../interfaces/engine/IDocumentEngine.sol";

/**
 * @title CMTAT document engine module mock
 * @dev Test-only contract that wires DocumentEngineModule on top of CMTAT core.
 */
contract CMTATDocumentEngineModuleMock is CMTATBaseCore, DocumentEngineModule {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        IERC1643 documentEngine_
    ) public initializer {
        __CMTAT_init(admin, ERC20Attributes_);
        __DocumentEngineModule_init_unchained(documentEngine_);
    }

    function _authorizeDocumentManagement() internal virtual override(DocumentEngineModule) onlyRole(DOCUMENT_ENGINE_ROLE) {}

    /**
     * @dev Advertise ERC-1643 support (`type(IERC1643).interfaceId` == 0xecfecec8) for the
     * engine variant, matching the in-contract variant which registers it in
     * {CMTATBaseAccessControl-supportsInterface}. Satisfies the ERC-1643 ERC-165 SHOULD.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(CMTATBaseCore) returns (bool) {
        return interfaceId == type(IERC1643).interfaceId || super.supportsInterface(interfaceId);
    }
}
