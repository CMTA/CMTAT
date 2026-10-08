//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

import {CMTATStandardUpgradeable} from "../../deployment/CMTATStandardUpgradeable.sol";
import {CMTATV33TokenAttributeMigration} from "./CMTATV33TokenAttributeMigration.sol";

/**
* @title `CMTATStandardUpgradeable` with the v3.2.0 -> v3.3.0 `name` / `symbol` migration.
* @dev EXAMPLE / TESTING ONLY - NOT AUDITED, do not deploy as is. Upgrade target for a v3.2.0 `CMTATUpgradeable` proxy.
* Call {migrateFromV32} through `ProxyAdmin.upgradeAndCall` in the upgrade transaction.
*/
contract CMTATStandardUpgradeableV33MigrationMock is CMTATStandardUpgradeable, CMTATV33TokenAttributeMigration {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address forwarderIrrevocable) CMTATStandardUpgradeable(forwarderIrrevocable) {}

    /**
    * @notice One-time migration of `name` / `symbol` from the v3.2.0 storage layout.
    * @dev `reinitializer(2)`: a v3.2.0 proxy was initialized with version 1. Use a higher version if
    * the proxy already ran another reinitializer.
    */
    function migrateFromV32() external reinitializer(2) {
        (string memory name_, string memory symbol_) = _takeLegacyTokenAttributes();
        __TokenAttributeModule_init_unchained(name_, symbol_);
    }
}
