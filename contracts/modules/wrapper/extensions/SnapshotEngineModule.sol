//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {Errors} from "../../../libraries/Errors.sol";
import {ISnapshotEngine} from "../../../interfaces/engine/ISnapshotEngine.sol";

abstract contract SnapshotEngineModule is AuthorizationModule {
    /* ============ State Variables ============ */
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");
    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event SnapshotEngine(ISnapshotEngine indexed newSnapshotEngine);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.SnapshotModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SnapshotEngineModuleStorageLocation = 0x59b7f077fa4ad020f9053fd2197fef0113b19f0b11dcfe516e88cbc0e9226d00;
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
    function __SnapshotModule_init_unchained(ISnapshotEngine snapshotEngine_)
    internal onlyInitializing {
        if (address(snapshotEngine_) != address (0)) {
            SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
            _setSnapshotEngine($, snapshotEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function snapshotEngine() public view virtual returns (ISnapshotEngine) {
        SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
        return $._snapshotEngine;
    }

    /* ============  Restricted Functions ============ */
    /*
    * @notice set an SnapshotEngine if not already set
    * @dev once an SnapshotEngine is set, it is not possible to unset it
    */
    function setSnapshotEngine(
        ISnapshotEngine snapshotEngine_
    ) external onlyRole(SNAPSHOOTER_ROLE) {
        SnapshotEngineModuleStorage storage $ = _getSnapshotEngineModuleStorage();
        if ($._snapshotEngine == snapshotEngine_){
             revert Errors.CMTAT_SnapshotModule_SameValue();
        }
        _setSnapshotEngine($, snapshotEngine_);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setSnapshotEngine(
        SnapshotEngineModuleStorage storage $, ISnapshotEngine snapshotEngine_
    ) internal {
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
