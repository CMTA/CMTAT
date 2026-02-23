// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
/* ==== Engine === */
import {IFixDescriptorEngine, IFixDescriptorEngineModule} from "../../../interfaces/modules/IFixDescriptorEngineModule.sol";

abstract contract FixDescriptorEngineModule is Initializable, IFixDescriptorEngineModule {
    /* ============ State Variables ============ */
    bytes32 public constant DESCRIPTOR_ENGINE_ROLE = keccak256("DESCRIPTOR_ENGINE_ROLE");

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.FixDescriptorEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant FixDescriptorEngineModuleStorageLocation = 0xc09aa28957960c2b82e3fad477567fe122f23bca69560181151331ec7041c600;
    /* ==== ERC-7201 State Variables === */
    struct FixDescriptorEngineModuleStorage {
        IFixDescriptorEngine _fixDescriptorEngine;
    }

    /* ============ Modifier ============ */
    modifier onlyDescriptorEngine() {
        _authorizeFixDescriptorEngine();
        _;
    }
    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __FixDescriptorEngineModule_init_unchained(IFixDescriptorEngine fixDescriptorEngine_)
    internal virtual onlyInitializing {
        if (address(fixDescriptorEngine_) != address (0)) {
            FixDescriptorEngineModuleStorage storage $ = _getFixDescriptorEngineModuleStorage();
            _setFixDescriptorEngine($, fixDescriptorEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============  State Restricted Functions ============ */
    /**
    * @inheritdoc IFixDescriptorEngineModule
    * @custom:access-control
    * - The caller must have the `DESCRIPTOR_ENGINE_ROLE`.
    */
    function setFixDescriptorEngine(
        IFixDescriptorEngine fixDescriptorEngine_
    ) public virtual override(IFixDescriptorEngineModule) onlyDescriptorEngine  {
        FixDescriptorEngineModuleStorage storage $ = _getFixDescriptorEngineModuleStorage();
        require($._fixDescriptorEngine != fixDescriptorEngine_, CMTAT_FixDescriptorModule_SameValue());
        if (address(fixDescriptorEngine_) != address(0)) {
            address engineToken = fixDescriptorEngine_.token();
            require(
                engineToken == address(this),
                CMTAT_FixDescriptorModule_InvalidTokenBinding(address(this), engineToken)
            );
        }
        _setFixDescriptorEngine($, fixDescriptorEngine_);
    }

    
    /* ============ View functions ============ */

    /**
    * @inheritdoc IFixDescriptorEngineModule
    */
    function fixDescriptorEngine() public view virtual override(IFixDescriptorEngineModule) returns (IFixDescriptorEngine) {
        FixDescriptorEngineModuleStorage storage $ = _getFixDescriptorEngineModuleStorage();
        return $._fixDescriptorEngine;
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _setFixDescriptorEngine(
        FixDescriptorEngineModuleStorage storage $, IFixDescriptorEngine fixDescriptorEngine_
    ) internal virtual {
        $._fixDescriptorEngine = fixDescriptorEngine_;
        emit FixDescriptorEngine(fixDescriptorEngine_);
    }

    /* ============ Access Control ============ */
    function _authorizeFixDescriptorEngine() internal virtual;
    /* ============ ERC-7201 ============ */
    function _getFixDescriptorEngineModuleStorage() private pure returns (FixDescriptorEngineModuleStorage storage $) {
        assembly {
            $.slot := FixDescriptorEngineModuleStorageLocation
        }
    }


}
