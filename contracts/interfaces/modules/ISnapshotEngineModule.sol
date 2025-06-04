// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Engine === */
import {ISnapshotEngine} from "../engine/ISnapshotEngine.sol";

/*
* @dev minimum interface to define a DocumentEngineModule
*/
interface ISnapshotEngineModule {
    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event SnapshotEngine(ISnapshotEngine indexed newSnapshotEngine);
    /* ============ Error ============ */
    error CMTAT_SnapshotModule_SameValue();
    /* ============ Functions ============ */
    /*
    * @notice Set the snapshotEngine
    */
    function setSnapshotEngine(
        ISnapshotEngine snapshotEngine_
    ) external;
    /**
    * @notice returns the current snapshotEngine
    */
    function  snapshotEngine() external view returns (ISnapshotEngine);
}
