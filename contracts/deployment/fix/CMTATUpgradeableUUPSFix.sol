//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {CMTATBaseFix} from "../../modules/1_CMTATBaseFix.sol";
import {IFixDescriptorEngine} from "../../interfaces/engine/IFixDescriptorEngine.sol";
import {ICMTATConstructor} from "../../interfaces/technical/ICMTATConstructor.sol";

/**
 * @title CMTATUpgradeableUUPSFix
 * @notice UUPS proxy-compatible deployment variant with FIX descriptor support.
 */
contract CMTATUpgradeableUUPSFix is CMTATBaseFix, UUPSUpgradeable {
    bytes32 public constant PROXY_UPGRADE_ROLE = keccak256("PROXY_UPGRADE_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initializeFix(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_,
        IFixDescriptorEngine fixDescriptorEngine_
    ) public override(CMTATBaseFix) initializer {
        CMTATBaseFix.initializeFix(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_,
            fixDescriptorEngine_
        );
        __UUPSUpgradeable_init_unchained();
    }

    function _authorizeUpgrade(address) internal override onlyRole(PROXY_UPGRADE_ROLE) {}
}

