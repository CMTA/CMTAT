//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/* ==== Base === */
import {CMTATBaseRuleEngine} from "./1_CMTATBaseRuleEngine.sol";

/* ==== Extensions === */
import {FixDescriptorEngineModule} from "./wrapper/extensions/FixDescriptorEngineModule.sol";

/* ==== Interfaces === */
import {IFixDescriptorEngine} from "../interfaces/engine/IFixDescriptorEngine.sol";
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";

/**
 * @title CMTATBaseFix
 * @notice CMTAT base contract with FIX descriptor support
 * @dev Extends CMTATBaseCommon with FixDescriptorEngineModule for ERC-FIX compliance
 * This base contract adds FIX Protocol descriptor functionality to CMTAT tokens,
 * enabling seamless integration with traditional financial infrastructure
 */
abstract contract CMTATBaseFix is CMTATBaseRuleEngine, FixDescriptorEngineModule {
    /*//////////////////////////////////////////////////////////////
                         CONTEXT / ACCESS OVERRIDES
    //////////////////////////////////////////////////////////////*/

    function _checkFixDescriptorRole() internal view override {
        _checkRole(FIX_DESCRIPTOR_ROLE, _msgSender());
    }

    /*//////////////////////////////////////////////////////////////
                            INITIALIZER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function initializeFix(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_,
        IFixDescriptorEngine fixDescriptorEngine_
    ) public virtual initializer {
        CMTATBaseRuleEngine.initialize(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_
        );

        _grantRole(FIX_DESCRIPTOR_ROLE, admin);
        __FixDescriptorEngineModule_init_unchained(fixDescriptorEngine_);
    }
}
