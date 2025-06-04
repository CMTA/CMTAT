//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Engine === */
import {ISnapshotEngine, ISnapshotEngineModule} from "../../../interfaces/modules/ISnapshotEngineModule.sol";

abstract contract SnapshotEngineModule is ISnapshotEngineModule, AuthorizationModule {
    /* ============ State Variables ============ */
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");

    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.SnapshotEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SnapshotEngineModuleStorageLocation = 0x1387b97dfab601d3023cb57858a6be29329babb05c85597ddbe4926c1193a900;
    /* ==== ERC-7201 State Variables === */
    struct SnapshotEngineModuleStorage {
        ISnapshotEngine _snapshotEngine;
    }
    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __SnapshotEngineModule_init_unchained(ISnapshotEngine snapshotEngine_)
    internal virtual onlyInitializing {
        if (address(snapshotEngine_) != address (0)) {
            SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
            _setSnapshotEngine($, snapshotEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc ISnapshotEngineModule
    */
    function snapshotEngine() public view virtual override(ISnapshotEngineModule) returns (ISnapshotEngine) {
        SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
        return $._snapshotEngine;
    }

    /* ============  Restricted Functions ============ */

    function setSnapshotEngine(
        ISnapshotEngine snapshotEngine_
    ) external virtual override(ISnapshotEngineModule) onlyRole(SNAPSHOOTER_ROLE) {
        SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
        require($._snapshotEngine != snapshotEngine_, CMTAT_SnapshotModule_SameValue());
        _setSnapshotEngine($, snapshotEngine_);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setSnapshotEngine(
        SnapshotEngineModuleStorage storage $, ISnapshotEngine snapshotEngine_
    ) internal virtual {
        $._snapshotEngine = snapshotEngine_;
        emit SnapshotEngine(snapshotEngine_);
    }

    /* ============ ERC-7201 ============ */
    function _getSnapshotEngineModuleStorage() private pure returns (SnapshotEngineModuleStorage storage $) {
        assembly {
            $.slot := SnapshotEngineModuleStorageLocation
        }
    }
}
