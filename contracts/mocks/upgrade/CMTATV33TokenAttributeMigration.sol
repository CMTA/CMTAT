//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

/**
* @title Example migration of `name` / `symbol` for proxies upgraded from CMTAT v3.2.0 or earlier.
* @dev
* EXAMPLE / TESTING ONLY - NOT AUDITED. Not part of the CMTAT release; do not deploy as is.
*
* In v3.3.0, `name` and `symbol` moved from `CMTAT.storage.ERC20BaseModule` to
* `CMTAT.storage.TokenAttributeModule`. After a plain upgrade, `name()` / `symbol()` read the new,
* empty slot. This contract reads the values from their v3.2.0 location and clears the old slots;
* the deployment-specific migration mock writes them to the new location with
* `__TokenAttributeModule_init_unchained`, which it already inherits. `decimals` shares the v3.2.0 struct but is not touched: it keeps its
* place in v3.3.0.
*
* The values are read on-chain, so the migration takes no argument and cannot be fed wrong values.
* It must run in the upgrade transaction (`upgradeToAndCall` / `ProxyAdmin.upgradeAndCall`), so that
* the token never exposes an empty name, and because the `migrateFromV32()` functions of the example
* mocks have no access control: called later, anyone could run them and overwrite a name set by the
* admin in the meantime. See doc/technical/breaking-changes.md (S1).
*/
abstract contract CMTATV33TokenAttributeMigration {
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant LegacyERC20BaseModuleStorageLocation = 0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00;

    /// @dev `ERC20BaseModuleStorage` layout up to v3.2.0.
    struct LegacyERC20BaseModuleStorage {
        uint8 _decimals;
        string _name;
        string _symbol;
    }

    /// @dev Returns the v3.2.0 `name` / `symbol` and clears their slots. `decimals` is not touched.
    function _takeLegacyTokenAttributes() internal returns (string memory name_, string memory symbol_) {
        LegacyERC20BaseModuleStorage storage $ = _getLegacyERC20BaseModuleStorage();
        name_ = $._name;
        symbol_ = $._symbol;
        delete $._name;
        delete $._symbol;
    }

    function _getLegacyERC20BaseModuleStorage() private pure returns (LegacyERC20BaseModuleStorage storage $) {
        assembly {
            $.slot := LegacyERC20BaseModuleStorageLocation
        }
    }
}
