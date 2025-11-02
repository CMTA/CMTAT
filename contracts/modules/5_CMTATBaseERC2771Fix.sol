//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin ==== */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/* ==== Base === */
import {CMTATBaseERC2771} from "./4_CMTATBaseERC2771.sol";
import {CMTATBaseERC20CrossChain} from "./3_CMTATBaseERC20CrossChain.sol";
import {CMTATBaseERC1404} from "./2_CMTATBaseERC1404.sol";

/* ==== Extensions === */
import {FixDescriptorEngineModule} from "./wrapper/extensions/FixDescriptorEngineModule.sol";
import {ERC2771ContextUpgradeable} from "./wrapper/options/ERC2771Module.sol";

/* ==== Interfaces === */
import {IFixDescriptorEngine} from "../interfaces/engine/IFixDescriptorEngine.sol";
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";

/**
 * @title CMTATBaseERC2771Fix
 * @notice CMTAT base contract with FIX descriptor support
 * @dev Extends CMTATBaseERC2771 with FixDescriptorEngineModule for ERC-FIX compliance
 * This is the top-level base contract for CMTAT tokens with FIX Protocol descriptor support,
 * enabling seamless integration with traditional financial infrastructure
 */
abstract contract CMTATBaseERC2771Fix is
    CMTATBaseERC2771,
    FixDescriptorEngineModule
{
    /*//////////////////////////////////////////////////////////////
                            CONTEXT OVERRIDES
    //////////////////////////////////////////////////////////////*/

    function _msgSender()
        internal
        view
        virtual
        override(CMTATBaseERC2771)
        returns (address)
    {
        return CMTATBaseERC2771._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(CMTATBaseERC2771)
        returns (bytes calldata)
    {
        return CMTATBaseERC2771._msgData();
    }

    function _contextSuffixLength()
        internal
        view
        virtual
        override(CMTATBaseERC2771)
        returns (uint256)
    {
        return CMTATBaseERC2771._contextSuffixLength();
    }

    function _checkFixDescriptorRole() internal view override {
        _checkRole(FIX_DESCRIPTOR_ROLE, _msgSender());
    }

    /*//////////////////////////////////////////////////////////////
                         ACCESS CONTROL OVERRIDES
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initialize the proxy contract with FIX descriptor engine support
     * @dev The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param extraInformationAttributes_ tokenId, terms, information
     * @param engines_ external contract engines (rule, snapshot, document)
     * @param fixDescriptorEngine_ external FIX descriptor engine (optional)
     */
    function initializeFix(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_,
        IFixDescriptorEngine fixDescriptorEngine_
    ) public virtual initializer {
        __CMTAT_init_withFix(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_,
            fixDescriptorEngine_
        );
    }

    /**
     * @dev Calls the different initialize functions from the different modules including FIX
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param ExtraInformationAttributes_ tokenId, terms, information
     * @param engines_ external contract engines (rule, snapshot, document)
     * @param fixDescriptorEngine_ external FIX descriptor engine (optional)
     */
    function __CMTAT_init_withFix(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory ExtraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_,
        IFixDescriptorEngine fixDescriptorEngine_
    ) internal virtual onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();

        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();

        // OpenZeppelin
        __CMTAT_openzeppelin_init_unchained();

        /* Internal Modules */
        __CMTAT_internal_init_unchained_withFix(engines_);

        /* Wrapper modules */
        __CMTAT_modules_init_unchained_withFix(
            admin,
            ERC20Attributes_,
            ExtraInformationAttributes_,
            engines_,
            fixDescriptorEngine_
        );
    }

    /**
     * @dev CMTAT internal module initialization with FIX
     * @param engines_ external contract engines
     */
    function __CMTAT_internal_init_unchained_withFix(
        ICMTATConstructor.Engine memory engines_
    ) internal virtual onlyInitializing {
        __ValidationRuleEngine_init_unchained(engines_.ruleEngine);
    }

    /**
     * @dev CMTAT wrapper modules initialization with FIX
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param extraInformationAttributes_ tokenId, terms, information
     * @param engines_ external contract engines (rule, snapshot, document)
     * @param fixDescriptorEngine_ external FIX descriptor engine (optional)
     */
    function __CMTAT_modules_init_unchained_withFix(
        address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_,
        IFixDescriptorEngine fixDescriptorEngine_
    ) internal virtual onlyInitializing {
        // Initialize common modules
        __CMTAT_commonModules_init_unchained(
            admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_.snapshotEngine,
            engines_.documentEngine
        );

        _grantRole(FIX_DESCRIPTOR_ROLE, admin);

        // Initialize FIX descriptor module
        __FixDescriptorEngineModule_init_unchained(fixDescriptorEngine_);
    }
}
