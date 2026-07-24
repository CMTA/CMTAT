//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRuleEngine} from "../../interfaces/engine/IRuleEngine.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {RuleEngineInterfaceId} from "../../library/RuleEngineInterfaceId.sol";

/**
* @title A malicious RuleEngine that reenters the token during `transferred`.
* @dev
* TESTING ONLY - never deploy this.
*
* The token calls `transferred(...)` from `_checkTransferred`, i.e. after the active-balance
* (frozen) check but before `ERC20Upgradeable._transfer` moves any balance. A rule engine that
* calls back into the token during that window is re-evaluated against the *same* pre-transfer
* balance, so without a reentrancy guard both the outer and the inner transfer can independently
* pass `_checkActiveBalanceAndRevert` and together move more than the unfrozen amount.
*
* This mock reproduces exactly that: on the first `transferred` callback it performs one nested
* `transferFrom`, then disarms itself so the nested call terminates the recursion.
*
* It intentionally implements no rules: every `canTransfer*` returns true, so the only behaviour
* under test is the reentrancy, not any compliance logic.
*/
contract RuleEngineReentrantMock is ERC165, IRuleEngine {
    IERC20 public token;
    address public victim;
    address public attacker;
    uint256 public nestedValue;
    bool public armed;
    /// @notice True once a nested `transferFrom` has been attempted.
    bool public reentered;
    /// @notice True if the nested `transferFrom` returned without reverting.
    bool public reentrySucceeded;
    /// @notice When true, the nested call is made without try/catch so its revert bubbles up.
    bool public bubbleRevert;

    function setBubbleRevert(bool bubble_) external {
        bubbleRevert = bubble_;
    }

    function arm(
        IERC20 token_,
        address victim_,
        address attacker_,
        uint256 nestedValue_
    ) external {
        token = token_;
        victim = victim_;
        attacker = attacker_;
        nestedValue = nestedValue_;
        armed = true;
        reentered = false;
        reentrySucceeded = false;
    }

    /* ============ IRuleEngine - state ============ */

    function transferred(address /*spender*/, address from, address to, uint256 value) public override {
        _attack(from, to, value);
    }

    function transferred(address from, address to, uint256 value) public override {
        _attack(from, to, value);
    }

    /* ============ IRuleEngine - views ============ */

    function canTransfer(address, address, uint256) public pure override returns (bool) {
        return true;
    }

    function canTransferFrom(address, address, address, uint256) public pure override returns (bool) {
        return true;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID || super.supportsInterface(interfaceId);
    }

    /* ============ Internal ============ */

    function _attack(address /*from*/, address /*to*/, uint256 /*value*/) internal {
        if (!armed) {
            return;
        }
        // Disarm first so the nested call does not recurse forever
        armed = false;
        reentered = true;
        // Reenter the token while the outer transfer has not yet moved any balance
        if (bubbleRevert) {
            token.transferFrom(victim, attacker, nestedValue);
            reentrySucceeded = true;
            return;
        }
        try token.transferFrom(victim, attacker, nestedValue) returns (bool) {
            reentrySucceeded = true;
        } catch {
            reentrySucceeded = false;
        }
    }
}
