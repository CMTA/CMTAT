// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {FixDescriptorEngineModule} from "../modules/wrapper/extensions/FixDescriptorEngineModule.sol";
import {IFixDescriptorEngine} from "../interfaces/engine/IFixDescriptorEngine.sol";

/**
 * @title FixDescriptorEngineModuleHarness
 * @notice Test helper harness that exposes the FixDescriptorEngineModule initializer workflow.
 */
contract FixDescriptorEngineModuleHarness is FixDescriptorEngineModule, AccessControlUpgradeable {
    /// @notice Initializes access control and optionally wires an initial FIX descriptor engine.
    function initialize(address admin, IFixDescriptorEngine engine) external initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(FIX_DESCRIPTOR_ROLE, admin);
        __FixDescriptorEngineModule_init_unchained(engine);
    }

    /// @notice Convenience helper used in tests to grant the FIX descriptor role.
    function grantFixRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(FIX_DESCRIPTOR_ROLE, account);
    }

    function _checkFixDescriptorRole() internal view override {
        _checkRole(FIX_DESCRIPTOR_ROLE, _msgSender());
    }
}

