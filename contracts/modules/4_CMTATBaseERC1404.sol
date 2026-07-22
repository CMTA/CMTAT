// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseRuleEngine} from "./3_CMTATBaseRuleEngine.sol";
import {CMTATBaseAccessControl} from "./2_CMTATBaseAccessControl.sol";
/* ==== Wrapper === */
// re-exported to keep {CMTATBaseERC20CrossChain} importing ERC20Upgradeable through this file
import {ERC20Upgradeable} from "./wrapper/core/ERC20BaseModule.sol";
// Controllers
import {ValidationModuleERC1404, IERC1404, IERC1404Extend} from "./wrapper/extensions/ValidationModule/ValidationModuleERC1404.sol";
import {ValidationModuleRuleEngine} from "./wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol";
import {ERC1404ExtendInterfaceId} from "../library/ERC1404ExtendInterfaceId.sol";

abstract contract CMTATBaseERC1404 is
    CMTATBaseRuleEngine,
    ValidationModuleERC1404
{
    /**
    * @dev ERC20EnforcementModule error text
    */
    string internal constant TEXT_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE =
        "AddrFrom:insufficientActiveBalance";
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @inheritdoc ValidationModuleERC1404
    */
    function messageForTransferRestriction(
        uint8 restrictionCode
    )  public view virtual override(ValidationModuleERC1404)  returns (string memory message) {
        if(restrictionCode == uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE)){
            return TEXT_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE;
        } else {
            return ValidationModuleERC1404.messageForTransferRestriction(restrictionCode);
        }

    }

    /**
    * @inheritdoc ValidationModuleRuleEngine
    */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public virtual override (CMTATBaseRuleEngine, ValidationModuleRuleEngine) view returns (bool) {
        return CMTATBaseRuleEngine.canTransfer(from, to, value);
    }

    /**
    * @inheritdoc ValidationModuleRuleEngine
    */
    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual override (CMTATBaseRuleEngine, ValidationModuleRuleEngine) view returns (bool) {
        return CMTATBaseRuleEngine.canTransferFrom(spender, from, to, value);
    }

    /**
    * @notice ERC-165 interface detection
    * @dev advertises support for both the canonical ERC-1404 interface
    * (`IERC1404`, id `0xab84a5c8`) and its CMTAT extension
    * (`IERC1404Extend`, id `0x78a8de7d`).
    * @dev The extension id is taken from {ERC1404ExtendInterfaceId} because
    * Solidity's `type(IERC1404Extend).interfaceId` excludes inherited
    * functions and would therefore only cover `detectTransferRestrictionFrom`.
    * @inheritdoc CMTATBaseAccessControl
    */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(CMTATBaseAccessControl) returns (bool) {
        return
            interfaceId == type(IERC1404).interfaceId ||
            interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID ||
            super.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @dev Delegates the frozen-balance check to {ERC20EnforcementModuleInternal-_checkActiveBalance},
    * the same predicate the transfer path enforces, so the predicted restriction and the actual
    * transfer outcome cannot drift. In particular a zero-value transfer, which `_checkActiveBalance`
    * treats as always valid, is reported as unrestricted here as well.
    * @return code The restriction code (0 = no restriction).
    */
    function _detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) internal virtual override( ValidationModuleERC1404) view  returns (uint8 code) {
        (bool isValid, ) = _checkActiveBalance(from, value);
        if (!isValid) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE);
        }
        return ValidationModuleERC1404._detectTransferRestriction(from, to, value);
    }
}
