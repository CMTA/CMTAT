//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseFix} from "../../modules/1_CMTATBaseFix.sol";

/**
 * @title CMTATUpgradeableFix
 * @notice Upgradeable (Transparent/Beacon) deployment variant with FIX descriptors.
 */
contract CMTATUpgradeableFix is CMTATBaseFix {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }
}

