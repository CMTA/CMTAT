//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

import {CMTATUpgradeableSnapshot} from "../../deployment/snapshot/CMTATUpgradeableSnapshot.sol";
import {CMTATV33TokenAttributeMigration} from "./CMTATV33TokenAttributeMigration.sol";

/**
* @title `CMTATUpgradeableSnapshot` with the v3.2.0 -> v3.3.0 `name` / `symbol` migration.
* @dev EXAMPLE / TESTING ONLY - NOT AUDITED, do not deploy as is. Upgrade target for a v3.2.0 `CMTATUpgradeable` proxy that uses a
* SnapshotEngine: in v3.3.0 the Standard variant no longer calls the SnapshotEngine, the Snapshot
* variant does, and it reads the engine address from the unchanged `CMTAT.storage.SnapshotEngineModule`.
*/
contract CMTATUpgradeableSnapshotV33MigrationMock is CMTATUpgradeableSnapshot, CMTATV33TokenAttributeMigration {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address forwarderIrrevocable) CMTATUpgradeableSnapshot(forwarderIrrevocable) {}

    /// @notice One-time migration of `name` / `symbol` from the v3.2.0 storage layout.
    /// @dev No access control: MUST be called through `ProxyAdmin.upgradeAndCall` in the upgrade transaction.
    function migrateFromV32() external reinitializer(2) {
        (string memory name_, string memory symbol_) = _takeLegacyTokenAttributes();
        __TokenAttributeModule_init_unchained(name_, symbol_);
    }
}
