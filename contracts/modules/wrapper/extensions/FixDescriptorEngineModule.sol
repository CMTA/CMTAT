//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Engine === */
import {IFixDescriptorEngine} from "../../../interfaces/engine/IFixDescriptorEngine.sol";
import {IFixDescriptorEngineModule} from "../../../interfaces/modules/IFixDescriptorEngineModule.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title FixDescriptorEngine Module
 * @notice Delegates FIX descriptor management to an external engine following ERC-FIX spec
 * @dev Stores reference to IFixDescriptorEngine and forwards all calls
 * Uses ERC-7201 namespaced storage pattern to prevent collisions
 */

abstract contract FixDescriptorEngineModule is IFixDescriptorEngineModule, Initializable {
    /* ============ Roles ============ */
    bytes32 public constant FIX_DESCRIPTOR_ROLE = keccak256("FIX_DESCRIPTOR_ROLE");

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.FixDescriptorEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant FixDescriptorEngineModuleStorageLocation =
        0xa53cb59b6022663116b97fd8896a8d8c96544a6d32d4ec30cfa96e5d8df7e300;

    /* ==== ERC-7201 State Variables === */
    struct FixDescriptorEngineModuleStorage {
        address _fixDescriptorEngine;
    }

    modifier onlyFixDescriptorRole() {
        _checkFixDescriptorRole();
        _;
    }

    /* ============  Initializer Function ============ */

    /**
     * @dev Sets a FixDescriptorEngine if address is not zero
     * @param fixDescriptorEngine_ The initial FIX descriptor engine
     */
    function __FixDescriptorEngineModule_init_unchained(
        IFixDescriptorEngine fixDescriptorEngine_
    ) internal virtual onlyInitializing {
        if (address(fixDescriptorEngine_) != address(0)) {
            _setFixDescriptorEngine(
                _getFixDescriptorEngineModuleStorage(),
                fixDescriptorEngine_
            );
        }
    }

    /*//////////////////////////////////////////////////////////////
                        PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IFixDescriptorEngineModule
     */
    function fixDescriptorEngine()
        public
        view
        virtual
        override(IFixDescriptorEngineModule)
        returns (address fixDescriptorEngine_)
    {
        return _getFixDescriptorEngineModuleStorage()._fixDescriptorEngine;
    }

    /**
     * @inheritdoc IFixDescriptorEngineModule
     */
    /* ============  Restricted Functions ============ */

    /**
     * @inheritdoc IFixDescriptorEngineModule
     */
    function setFixDescriptorEngine(
        IFixDescriptorEngine fixDescriptorEngine_
    ) public virtual override(IFixDescriptorEngineModule) onlyFixDescriptorRole {
        FixDescriptorEngineModuleStorage storage $ = _getFixDescriptorEngineModuleStorage();
        address current = $._fixDescriptorEngine;
        address next = address(fixDescriptorEngine_);

        require(current != next, CMTAT_FixDescriptorEngineModule_SameValue());

        _setFixDescriptorEngine($, fixDescriptorEngine_);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Internal function to set the FIX descriptor engine
     * @param $ Storage pointer to module storage
     * @param fixDescriptorEngine_ The new engine address
     */
    function _setFixDescriptorEngine(
        FixDescriptorEngineModuleStorage storage $,
        IFixDescriptorEngine fixDescriptorEngine_
    ) internal virtual {
        $._fixDescriptorEngine = address(fixDescriptorEngine_);
        emit FixDescriptorEngine(fixDescriptorEngine_);
    }

    /* ============ ERC-7201 Storage Access ============ */

    /**
     * @dev Returns the storage pointer for this module using ERC-7201
     */
    function _getFixDescriptorEngineModuleStorage()
        private
        pure
        returns (FixDescriptorEngineModuleStorage storage $)
    {
        assembly {
            $.slot := FixDescriptorEngineModuleStorageLocation
        }
    }

    function _checkFixDescriptorRole() internal view virtual;
}
