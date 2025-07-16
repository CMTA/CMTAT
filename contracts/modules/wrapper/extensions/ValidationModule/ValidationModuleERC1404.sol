//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;


/* ==== Tokenization === */
import {IERC1404, IERC1404Extend} from "../../../../interfaces/tokenization/draft-IERC1404.sol";
import {ValidationModuleRuleEngine, IRuleEngine} from "./ValidationModuleRuleEngine.sol";
/**
 * @dev Validation module (ERC-1404)
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleERC1404 is
   ValidationModuleRuleEngine, IERC1404Extend
{
    /* ============ State Variables ============ */
    string constant TEXT_TRANSFER_OK = "NoRestriction";
    string constant TEXT_UNKNOWN_CODE = "UnknownCode";

    /* EnforcementModule */
    string internal constant TEXT_TRANSFER_REJECTED_FROM_FROZEN =
        "AddrFromIsFrozen";

    string internal constant TEXT_TRANSFER_REJECTED_TO_FROZEN =
        "AddrToIsFrozen";

    string internal constant TEXT_TRANSFER_REJECTED_SPENDER_FROZEN =
        "AddrSpenderIsFrozen";

    /* PauseModule */
    string internal constant TEXT_TRANSFER_REJECTED_PAUSED =
        "EnforcedPause";

    /* Contract deactivated */
    string internal constant TEXT_TRANSFER_REJECTED_DEACTIVATED =
        "ContractDeactivated";

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice returns the human readable explaination 
     * corresponding to the error code returned by detectTransferRestriction
     * @param restrictionCode The error code returned by detectTransferRestriction
     * @return message The human readable explaination corresponding to the error code returned by detectTransferRestriction
     * @dev see {ERC-1404}
     */
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) public virtual view override(IERC1404) returns (string memory message) {
          IRuleEngine ruleEngine_ = ruleEngine();
        if (restrictionCode == uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK)) {
            return TEXT_TRANSFER_OK;
        } else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED)
        ) {
            return TEXT_TRANSFER_REJECTED_PAUSED;
        } else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_DEACTIVATED)
        ) {
            return TEXT_TRANSFER_REJECTED_DEACTIVATED;
        } else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_FROM_FROZEN;
        } else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_TO_FROZEN;
        }  else if (
            restrictionCode ==
            uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_SPENDER_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_SPENDER_FROZEN;
        } else if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.messageForTransferRestriction(restrictionCode);
        } else {
            return TEXT_UNKNOWN_CODE;
        }
    }
    
    /**
     * @notice check if value token can be transferred from `from` to `to`
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     * @return code of the rejection reason
     * @dev see {ERC-1404}
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public virtual view override(IERC1404) returns (uint8 code) {
         IRuleEngine ruleEngine_ = ruleEngine();
         uint8 codeReturn = _detectTransferRestriction(from, to, value);
         if(codeReturn != uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK) ){
            return codeReturn;
         } else if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.detectTransferRestriction(from, to, value);
        } else{
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual view override(IERC1404Extend) returns (uint8 code) {
        IRuleEngine ruleEngine_ = ruleEngine();
        if (isFrozen(spender)) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_SPENDER_FROZEN);
        } else {
            uint8 codeReturn = _detectTransferRestriction(from, to, value);
            if (codeReturn != uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK) ){
                return codeReturn;
            } else if (address(ruleEngine_) != address(0)) {
                return ruleEngine_.detectTransferRestrictionFrom(spender, from, to, value);
            } else { 
                return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
            }
        } 
    }

     /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @dev override this function to add further restriction
    */
    function _detectTransferRestriction(
        address from,
        address to,
        uint256 /* value */
    ) internal virtual view  returns (uint8 code) {
        if (deactivated()){
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_DEACTIVATED);
        } else if (paused()) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED);
        } else if (isFrozen(from)) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN);
        } else if (isFrozen(to)) {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN);
        } 
        else {
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }
}
