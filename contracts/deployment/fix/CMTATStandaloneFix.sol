//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseFix} from "../../modules/1_CMTATBaseFix.sol";
import {IFixDescriptorEngine} from "../../interfaces/engine/IFixDescriptorEngine.sol";
import {ICMTATConstructor} from "../../interfaces/technical/ICMTATConstructor.sol";

/**
 * @title CMTATStandaloneFix
 * @notice Standalone deployment that wires an external FIX descriptor engine.
 */
contract CMTATStandaloneFix is CMTATBaseFix {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_,
        IFixDescriptorEngine fixDescriptorEngine_
    ) {
        initializeFix(admin, ERC20Attributes_, extraInformationAttributes_, engines_, fixDescriptorEngine_);
    }
}

