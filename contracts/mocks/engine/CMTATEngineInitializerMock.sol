//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATUpgradeable} from "../../deployment/CMTATUpgradeable.sol";
import {IERC1643} from "../../interfaces/engine/IDocumentEngine.sol";
import {ISnapshotEngine} from "../../interfaces/engine/ISnapshotEngine.sol";

/**
 * @title CMTATEngineInitializerMock
 * @dev Mock contract to test engine module initializers that aren't called in standard deployments.
 * These initializers exist but are not used in production to reduce contract code size.
 *
 * This contract exposes:
 * - __SnapshotEngineModule_init_unchained() - sets SnapshotEngine during initialization
 * - __DocumentEngineModule_init_unchained() - sets DocumentEngine during initialization
 */
contract CMTATEngineInitializerMock is CMTATUpgradeable {
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) CMTATUpgradeable(forwarderIrrevocable) {
        // Nothing to do
    }

    /**
     * @dev Initialize with engines via their dedicated init functions.
     * This allows testing the uncovered initializer branches.
     * Uses reinitializer(2) to allow calling after initial initialize().
     * @param snapshotEngine_ The snapshot engine address (can be zero)
     * @param documentEngine_ The document engine address (can be zero)
     */
    function initializeWithEngines(
        ISnapshotEngine snapshotEngine_,
        IERC1643 documentEngine_
    ) public reinitializer(2) {
        // Call the uncovered initializers
        // These functions check for non-zero address internally
        __SnapshotEngineModule_init_unchained(snapshotEngine_);
        __DocumentEngineModule_init_unchained(documentEngine_);
    }
}
