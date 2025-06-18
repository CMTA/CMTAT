//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {CMTATBaseCommon,AccessControlUpgradeable} from "./0_CMTATBaseCommon.sol";
/* ==== Wrapper === */
// Use by detectTransferRestriction
import {ERC20BaseModule, ERC20Upgradeable} from "./wrapper/core/ERC20BaseModule.sol";
// Extensions
import {ERC20EnforcementModule, ERC20EnforcementModuleInternal} from "./wrapper/extensions/ERC20EnforcementModule.sol";
// Controllers
import {ValidationModuleERC1404, IERC1404, IERC1404Extend} from "./wrapper/extensions/ValidationModule/ValidationModuleERC1404.sol";
import {ValidationModuleRuleEngine} from "./wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol";
import {DocumentModule, DocumentEngineModule} from "./wrapper/options/DocumentModule.sol";
 /* ==== Interface and other library === */
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";
import {Errors} from "../libraries/Errors.sol";
import {CMTATBaseRuleEngine} from "./1_CMTATBaseRuleEngine.sol";
abstract contract CMTATBase is
    CMTATBaseRuleEngine,
    DocumentModule,
    ValidationModuleERC1404
{
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc ValidationModuleERC1404
    */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public virtual view override(ValidationModuleERC1404 ) returns (uint8 code) {
        uint256 frozenTokensLocal = ERC20EnforcementModule.getFrozenTokens(from);
        if(frozenTokensLocal > 0 ){
            uint256 activeBalance = ERC20Upgradeable.balanceOf(from) - frozenTokensLocal;
            if(value > activeBalance) {
                return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE);
            }
        } 
        return ValidationModuleERC1404.detectTransferRestriction(from, to, value);
    }

    /**
    * @inheritdoc ValidationModuleERC1404
    */
    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual view override(ValidationModuleERC1404 ) returns (uint8 code) {
       uint8 returnCode = detectTransferRestriction(from, to, value);
       if(returnCode != uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK)){
            return returnCode;
       } else{
            return ValidationModuleERC1404.detectTransferRestrictionFrom(spender, from, to, value);
       }
    }

    /**
    * @inheritdoc ValidationModuleERC1404
    */
    function messageForTransferRestriction(
        uint8 restrictionCode
    )  public view virtual override(ValidationModuleERC1404)  returns (string memory message) {
        if(restrictionCode == uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE)){
            return ERC20EnforcementModule.TEXT_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE;
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

    function getDocument(string memory name) public view  virtual override(DocumentEngineModule, DocumentModule) returns (Document memory document){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            return $._documentEngine.getDocument(name);
        } else{
            return $._documents[name] ;
        }
    }

    function getAllDocuments() public view virtual override(DocumentEngineModule, DocumentModule) returns (string[] memory documents){
        DocumentEngineModuleStorage storage $ = _getDocumentEngineModuleStorage();
        if(address($._documentEngine) != address(0)){
            documents =  $._documentEngine.getAllDocuments();
        } else {
            return $._documentNames;
        }
    }



function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable, CMTATBaseRuleEngine) returns (bool) {
        return CMTATBaseRuleEngine.hasRole(role, account);
    }
}
