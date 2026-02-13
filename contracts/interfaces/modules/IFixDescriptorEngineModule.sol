// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Engine === */
import {IFixDescriptorEngine} from "../engine/IFixDescriptorEngine.sol";

/**
 * @title IFixDescriptorEngineModule
 * @notice Minimal interface for integrating a FIX descriptor engine module.
 * @dev Provides methods to set and retrieve a FIX descriptor engine used for managing FIX descriptors.
 */
interface IFixDescriptorEngineModule {
    /* ============ Events ============ */
    /**
     * @notice Emitted when a new FIX descriptor engine is set.
     * @param newFixDescriptorEngine The address of the newly assigned FIX descriptor engine contract.
     */
    event FixDescriptorEngine(IFixDescriptorEngine indexed newFixDescriptorEngine);
    /* ============ Error ============ */
    /**
     * @dev Reverts if the new FIX descriptor engine is the same as the current one.
     */
    error CMTAT_FixDescriptorModule_SameValue();
    /* ============ Functions ============ */
    /**
     * @notice Sets the address of the FIX descriptor engine contract.
     * @dev The FIX descriptor engine is responsible for managing FIX descriptors and SBE data.
     * Emits a {FixDescriptorEngine} event.
     * Reverts with {CMTAT_FixDescriptorModule_SameValue} if the new engine is the same as the current one.
     * @param fixDescriptorEngine_ The new FIX descriptor engine contract address to set.
     */
    function setFixDescriptorEngine(
        IFixDescriptorEngine fixDescriptorEngine_
    ) external;
    /**
     * @notice Returns the currently set FIX descriptor engine.
     * @return The address of the active FIX descriptor engine contract.
     */
    function fixDescriptorEngine() external view returns (IFixDescriptorEngine);
}
