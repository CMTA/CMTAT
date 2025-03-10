//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {PauseModule}  from "../core/PauseModule.sol";
import {EnforcementModule} from "../core/EnforcementModule.sol";
/* ==== Tokenization === */
import {IERC1404} from "../../../interfaces/tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "../../../interfaces/tokenization/draft-IERC7551.sol";
/* ==== Engine === */
import {IRuleEngine} from "../../../interfaces/engine/IRuleEngine.sol";
/* ==== Other === */
import {Errors} from "../../../libraries/Errors.sol";
/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is
    Initializable,
    ContextUpgradeable,
    PauseModule,
    EnforcementModule,
    IERC1404,
    IERC3643ComplianceRead,
    IERC7551Compliance
{
    /* ============ State Variables ============ */
    string constant TEXT_TRANSFER_OK = "No restriction";
    string constant TEXT_UNKNOWN_CODE = "Unknown code";


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
    function __ValidationModule_init_unchained(
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

    /*
    * @notice set a RuleEngine
    * @param ruleEngine_ the call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function setRuleEngine(
        IRuleEngine ruleEngine_
    ) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        require($._ruleEngine != ruleEngine_, Errors.CMTAT_ValidationModule_SameValue());
        _setRuleEngine($,ruleEngine_);
    }

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
          ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (restrictionCode == uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_OK)) {
            return TEXT_TRANSFER_OK;
        } else if (
            restrictionCode ==
            uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED)
        ) {
            return TEXT_TRANSFER_REJECTED_PAUSED;
        } else if (
            restrictionCode ==
            uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_FROM_FROZEN;
        } else if (
            restrictionCode ==
            uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN)
        ) {
            return TEXT_TRANSFER_REJECTED_TO_FROZEN;
        } else if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.messageForTransferRestriction(restrictionCode);
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
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (paused()) {
            return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_PAUSED);
        } else if (isFrozen(from)) {
            return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_FROM_FROZEN);
        } else if (isFrozen(to)) {
            return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_REJECTED_TO_FROZEN);
        } else if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.detectTransferRestriction(from, to, value);
        } 
        else {
            return uint8(IERC1404.REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    function canMint(
        address /*from*/,
        address to,
        uint256 /*value */
    ) public view returns (bool) {
        return _canMintByModule(to);
    }


    function canBurn(
        address from,
        address /* to */,
        uint256  /*value */
    ) public view returns (bool) {
        return _canMintByModule(from);
    }

    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view override(IERC3643ComplianceRead, IERC7551Compliance) returns (bool) {
        if (!_canTransferByModule(from, to, value)) {
            return false;
        } else {
            return _canTransfer(from, to, value);
        }
    }

    function canApprove(
        address owner, address spender, uint256 value
    ) public view virtual returns (bool) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.canApprove(owner, spender, value);
        } else{
            return true;
        }
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ View functions ============ */
    function _canTransfer(
        address from,
        address to,
        uint256 value
    ) internal view virtual returns (bool) {
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (address($._ruleEngine) != address(0)) {
            return $._ruleEngine.canTransfer(from, to, value);
        } else{
            return true;
        }
    }

    /**
    * @dev function used by canTransfer and operateOnTransfer
    * Block mint if the contract is deactivated (PauseModule) 
    * or if to is frozen
    */
    function _canMintByModule(
        address to
    ) internal view virtual returns (bool) {
        if(deactivated()){
            // can not mint or burn if the contract is deactivated
            return false;
        }
        if( isFrozen(to) ){
            return false;
        }
        return true;
    }


    /**
    * @dev function used by canTransfer and operateOnTransfer
    * Block burn if the contract is deactivated (PauseModule) 
    * Contrary to `_canMintByModule`, 
    * this function does not return false if from or to is frozen.
    * An issuer should be able to burn token from a frozen address.
    */
    function _canBurnByModule(
        address to
    ) internal view virtual returns (bool) {
        if(deactivated()){
            // can not mint or burn if the contract is deactivated
            return false;
        }
        return true;
    }

    /**
    @dev function used by canTransfer and operateOnTransfer
     */
    function _canTransferByModule(
        address from,
        address to,
        uint256 /*value*/
    ) internal view virtual returns (bool) {
        if( isFrozen(from) || isFrozen(to) || paused() ){
            return false;
        }
        return true;
      
    }

    /* ============ State functions ============ */
    /*
    * @dev set a RuleEngine
    * @param ruleEngine_ 
    * The call will be reverted if the new value of ruleEngine is the same as the current one
    */
    function _setRuleEngine(
        ValidationModuleInternalStorage storage $,
        IRuleEngine ruleEngine_
    )  internal {
        $._ruleEngine = ruleEngine_;
        emit RuleEngine(ruleEngine_);
    }

    function _operateOnTransfer(address from, address to, uint256 value) internal returns (bool){
        if (!_canTransferByModule(from, to, value)){
            return false;
        } else{
            ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
            if (address($._ruleEngine) != address(0)){
                return $._ruleEngine.transferred(from, to, value);
            }else {
                return true;
            }
        }
    }


    function _canApprove(address owner, address spender, uint256 value) internal view returns (bool){
        ValidationModuleInternalStorage storage $ = _getValidationModuleInternalStorage();
        if (address($._ruleEngine) != address(0)){
                return $._ruleEngine.canApprove(owner, spender, value);
        }else{
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
