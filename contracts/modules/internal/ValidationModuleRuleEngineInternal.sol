//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
/* ==== Engine === */
import {IRuleEngine} from "../../interfaces/engine/IRuleEngine.sol";

/*
 * @dev Set a ruleEngine for the ValidationModule
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleRuleEngineInternal is
    Initializable,
    ContextUpgradeable
{
    /* ============ Events ============ */
    /**
     * @dev Emitted when a rule engine is set.
     */
    event RuleEngine(IRuleEngine indexed newRuleEngine);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ValidationModuleRuleEngine")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ValidationModuleRuleEngineStorageLocation = 0xb3e8f29e401cfa802cad91001b5f9eb50decccdb111d80cb07177ab650b04700;
    /* ==== ERC-7201 State Variables === */
    struct ValidationModuleRuleEngineStorage {
        IRuleEngine _ruleEngine;
    }

    /* ============  Initializer Function ============ */
    function __ValidationModule_init_unchained(
        IRuleEngine ruleEngine_
    ) internal onlyInitializing {
        if (address(ruleEngine_) != address(0)) {
            _setRuleEngine(ruleEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    function ruleEngine() public view returns(IRuleEngine){
        ValidationModuleRuleEngineStorage storage $ = _getValidationModuleRuleEngineStorage();
        return $._ruleEngine;
    }

     /*
    * @dev set a RuleEngine
    * @param ruleEngine_ 
    * The call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function _setRuleEngine(
        IRuleEngine ruleEngine_
    )  internal virtual {
        ValidationModuleRuleEngineStorage storage $ = _getValidationModuleRuleEngineStorage();
        $._ruleEngine = ruleEngine_;
        emit RuleEngine(ruleEngine_);
    }

    /* ============ ERC-7201 ============ */
    function _getValidationModuleRuleEngineStorage() private pure returns (ValidationModuleRuleEngineStorage storage $) {
        assembly {
            $.slot := ValidationModuleRuleEngineStorageLocation
        }
    }
}
