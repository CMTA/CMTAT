//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IRuleEngine} from "../../interfaces/engine/IRuleEngine.sol";
/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleInternal is
    Initializable,
    ContextUpgradeable
{
    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event RuleEngine(IRuleEngine indexed newRuleEngine);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ValidationModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ValidationModuleInternalStorageLocation = 0xb3e8f29e401cfa802cad91001b5f9eb50decccdb111d80cb07177ab650b04700;
    /* ==== ERC-7201 State Variables === */
    struct ValidationModuleInternalStorage {
        IRuleEngine _ruleEngine;
    }
    /* ============  Initializer Function ============ */
    function __Validation_init_unchained(
        IRuleEngine ruleEngine_
    ) internal onlyInitializing {
        if (address(ruleEngine_) != address(0)) {
            ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
            _setRuleEngine($, ruleEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function ruleEngine() public view returns(IRuleEngine){
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        return $._ruleEngine;
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */

    function _validateTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view returns (bool) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.validateTransfer(from, to, amount);
        } else{
            return true;
        }
    }

    /**
    * @dev before making a call to this function, you have to check if a ruleEngine is set.
    */
    function _messageForTransferRestriction(
        ValidationModuleInternalStorage storage $,
        uint8 restrictionCode
    ) internal view returns (string memory) {
        return $._ruleEngine.messageForTransferRestriction(restrictionCode);
    }

    /**
    * @dev before making a call to this function, you have to check if a ruleEngine is set.
    */
    function _detectTransferRestriction(
        ValidationModuleInternalStorage storage $,
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint8) {
        return $._ruleEngine.detectTransferRestriction(from, to, amount);
    }

    /* ============ State functions ============ */
    /*
    * @dev set a RuleEngine
    * @param ruleEngine_ the call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function _setRuleEngine(
        ValidationModuleInternalStorage storage $,
        IRuleEngine ruleEngine_
    )  internal {
        $._ruleEngine = ruleEngine_;
        emit RuleEngine(ruleEngine_);
    }
    function _operateOnTransfer(address from, address to, uint256 amount) virtual internal returns (bool) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.operateOnTransfer(from, to, amount);
        } else{
            return true;
        }
    }


    /* ============ ERC-7201 ============ */
    function _getValidationModuleInternalStorage() internal pure returns (ValidationModuleInternalStorage storage $) {
        assembly {
            $.slot := ValidationModuleInternalStorageLocation
        }
    }
}
