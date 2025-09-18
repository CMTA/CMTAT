// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseRuleEngine} from "./1_CMTATBaseRuleEngine.sol";
/* ==== Wrapper === */
// Use by detectTransferRestriction
import {ERC20BaseModule, ERC20Upgradeable} from "./wrapper/core/ERC20BaseModule.sol";
// Extensions
import {ERC20EnforcementModule, ERC20EnforcementModuleInternal} from "./wrapper/extensions/ERC20EnforcementModule.sol";
// Controllers
import {ValidationModuleERC1404, IERC1404, IERC1404Extend} from "./wrapper/extensions/ValidationModule/ValidationModuleERC1404.sol";
import {ValidationModuleRuleEngine} from "./wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol";

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

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) internal virtual override( ValidationModuleERC1404) view  returns (uint8 code) {
        uint256 frozenTokensLocal = ERC20EnforcementModule.getFrozenTokens(from);
        if(frozenTokensLocal > 0 ){
            uint256 activeBalance = ERC20Upgradeable.balanceOf(from) - frozenTokensLocal;
            if(value > activeBalance) {
                return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE);
            }
        } 
        return ValidationModuleERC1404._detectTransferRestriction(from, to, value);
    }
}
