// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IFixDescriptorEngine} from "../engine/IFixDescriptorEngine.sol";

/**
 * @title IFixDescriptorEngineModule
 * @notice Interface for modules that delegate FIX descriptor management to an external engine
 */
interface IFixDescriptorEngineModule {

    /* ============ Events ============ */

    /**
     * @notice Emitted when a new FIX descriptor engine is set
     * @dev Indicates that the module now delegates FIX descriptor logic to a new external contract
     * @param newFixDescriptorEngine The address of the newly assigned FIX descriptor engine
     */
    event FixDescriptorEngine(IFixDescriptorEngine indexed newFixDescriptorEngine);

    /* ============ Errors ============ */

    /**
     * @notice Thrown when attempting to set the same FIX descriptor engine as the current one
     */
    error CMTAT_FixDescriptorEngineModule_SameValue();

    /* ============ Functions ============ */

    /**
     * @notice Sets a new FIX descriptor engine contract
     * @dev Only changes the engine if the new address is different from the current one
     * Throws {CMTAT_FixDescriptorEngineModule_SameValue} if the same engine is provided
     * Allows setting the engine to address(0) to disable FIX descriptors.
     * @param fixDescriptorEngine_ The address of the new IFixDescriptorEngine-compliant engine (or address(0) to clear)
     */
    function setFixDescriptorEngine(
        IFixDescriptorEngine fixDescriptorEngine_
    ) external;

    function fixDescriptorEngine() external view returns (address fixDescriptorEngine_);
}
