// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
/* ==== Engine === */
import {IRuleEngine} from "../../interfaces/engine/IRuleEngine.sol";

/*
 * @dev Set a ruleEngine for the ValidationModule
 *
 * Useful to restrict and validate transfers
 */
abstract contract ValidationModuleRuleEngineInternal is
    Initializable,
    ContextUpgradeable
{
    /* ============ Events ============ */
    /**
    * @notice Emitted when a new RuleEngine contract is set.
    * @param newRuleEngine The address of the RuleEngine that was configured.
    */
    event RuleEngine(IRuleEngine indexed newRuleEngine);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ValidationModuleRuleEngineInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ValidationModuleRuleEngineStorageLocation = 0x77c8cc897d160e7bf5b10921804e357da17ae27460d4a6b5d9b27ffddf159d00;
    /* ==== ERC-7201 State Variables === */
    struct ValidationModuleRuleEngineStorage {
        IRuleEngine _ruleEngine;
    }

    /* ============  Initializer Function ============ */
    function __ValidationRuleEngine_init_unchained(
        IRuleEngine ruleEngine_
    ) internal onlyInitializing {
        if (address(ruleEngine_) != address(0)) {
            _setRuleEngine(ruleEngine_);
        }
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
    * @notice Returns the current RuleEngine contract used for validation.
    * @return ruleEngine_ The address of the active RuleEngine.
    */
    function ruleEngine() public view returns(IRuleEngine){
        ValidationModuleRuleEngineStorage storage $ = _getValidationModuleRuleEngineStorage();
        return $._ruleEngine;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
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
