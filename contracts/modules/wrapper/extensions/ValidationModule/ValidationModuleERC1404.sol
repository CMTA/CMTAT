// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;


/* ==== Tokenization === */
import {IERC1404, IERC1404Extend} from "../../../../interfaces/tokenization/draft-IERC1404.sol";
import {ValidationModuleRuleEngine} from "./ValidationModuleRuleEngine.sol";
import {IRuleEngineERC1404} from "../../../../interfaces/engine/IRuleEngine.sol";

/**
 * @dev Validation module (ERC-1404)
 *
 * Useful for to restrict and validate transfers
 * Required a RuleEngine implementing the interface IRuleEngineERC1404
 *
 * @custom:scope {detectTransferRestriction} and {detectTransferRestrictionFrom} describe the
 * **holder transfer path only** — `transfer` and `transferFrom`. They do **not** govern the
 * mint and burn entry points, and the `address(0)` encoding of the ERC-1404 rework draft
 * (`from == address(0)` for a mint, `to == address(0)` for a burn) is **not** supported here:
 * a query built that way is answered as if it were a holder transfer, so it can report a
 * restriction the mint/burn path does not enforce (typically {PauseModule-paused}).
 *
 * The reason is structural, not an oversight. CMTAT exposes several entry points per
 * supply-changing operation and the **pause rule differs between them**:
 * - mint: `mint` / `batchMint` (`MINTER_ROLE`) are allowed while paused, `crosschainMint`
 *   (token bridge) is not;
 * - burn: `burn(address,uint256[,bytes])` / `batchBurn` (`BURNER_ROLE`) are allowed while paused,
 *   `burnFrom` (`BURNER_FROM_ROLE`), `burn(uint256)` (`BURNER_SELF_ROLE`) and `crosschainBurn`
 *   are not.
 *
 * `(from, to, value)` — and `(spender, from, to, value)` — carry no entry-point discriminator, and
 * the operator address does not identify one either (the same address may hold several burn roles),
 * so no single return value can describe every mint or every burn. Rather than designate a predictor
 * that would be right for one entry point and wrong for another, this module designates **none**.
 *
 * To predict a mint or a burn, use the module's own predicates instead — {canTransfer} /
 * {canTransferFrom}, which branch on the `address(0)` encoding through
 * {ValidationModule-_canTransferGenericByModule}, the same helper the enforcement path uses — and
 * the role/pause requirements documented per entry point.
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
     * @notice returns the human readable explanation 
     * corresponding to the error code returned by detectTransferRestriction
     * @param restrictionCode The error code returned by detectTransferRestriction
     * @return message The human readable explanation corresponding to the error code returned by detectTransferRestriction
     * @dev see {ERC-1404}
     */
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) public virtual view override(IERC1404) returns (string memory message) {
          IRuleEngineERC1404 ruleEngine_ = IRuleEngineERC1404(address(ruleEngine()));
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
     * @dev Scope: `transfer` / `transferFrom` only. Passing `address(0)` as `from` or `to` to query
     * a mint or a burn is **not** supported — see the scope note on this contract; use
     * {canTransfer} / {canTransferFrom} for those operations.
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) public virtual view override(IERC1404) returns (uint8 code) {
         IRuleEngineERC1404 ruleEngine_ = IRuleEngineERC1404(address(ruleEngine()));
         uint8 codeReturn = _detectTransferRestriction(from, to, value);
         if(codeReturn != uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK) ){
            return codeReturn;
         } else if (address(ruleEngine_) != address(0)) {
            return ruleEngine_.detectTransferRestriction(from, to, value);
        } else{
            return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_OK);
        }
    }

    /**
     * @notice check if `spender` can transfer `value` token from `from` to `to`
     * @param spender address The address initiating the delegated transfer
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     * @return code of the rejection reason
     * @dev see {ERC-1404} (rework draft, spender-aware extension)
     * @dev Scope: `transferFrom` only. The `spender` argument is the delegated-transfer initiator,
     * **not** a mint/burn operator: passing an operator with `from`/`to` set to `address(0)` to
     * predict a mint or a burn is not supported — see the scope note on this contract.
     * The `spender == from` case is deliberately evaluated through this path (no short-circuit to
     * {detectTransferRestriction}), because a frozen initiator blocks `transferFrom` even when it
     * owns the tokens.
     */
    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public virtual view override(IERC1404Extend) returns (uint8 code) {
        IRuleEngineERC1404 ruleEngine_ = IRuleEngineERC1404(address(ruleEngine()));
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
    * @return code The restriction code (0 = no restriction).
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
