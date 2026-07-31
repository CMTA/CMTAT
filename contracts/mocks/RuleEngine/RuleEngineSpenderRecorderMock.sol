//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

import {IRuleEngine} from "../../interfaces/engine/IRuleEngine.sol";
import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {RuleEngineInterfaceId} from "../../library/RuleEngineInterfaceId.sol";

/**
* @title A permissive RuleEngine that records which `transferred` overload the token invoked.
* @dev
* TESTING ONLY - never deploy this.
*
* CMTAT routes the RuleEngine `transferred` callback through
* {ValidationModuleRuleEngine-_callRuleEngineTransferred}, which selects the spender-aware
* 4-argument overload when a spender is present (a `transferFrom`) and the legacy 3-argument
* overload otherwise (a direct `transfer`, `mint` or `burn`). This mock records the arguments
* seen on the last callback so a test can assert the correct overload was taken - i.e. that the
* `spender != address(0)` dispatch was not inverted.
*
* Every `canTransfer*` returns true, so the only behaviour under test is the overload selection,
* not any compliance logic.
*/
contract RuleEngineSpenderRecorderMock is ERC165, IRuleEngine {
    /// @notice Spender seen on the last callback (address(0) on the 3-arg legacy path).
    address public lastSpender;
    /// @notice True if the last callback used the spender-aware 4-argument overload.
    bool public lastWasSpenderOverload;
    /// @notice Number of callbacks received across both overloads.
    uint256 public callCount;

    /* ============ IRuleEngine - state ============ */

    function transferred(address spender, address /*from*/, address /*to*/, uint256 /*value*/) public override {
        lastSpender = spender;
        lastWasSpenderOverload = true;
        callCount += 1;
    }

    function transferred(address /*from*/, address /*to*/, uint256 /*value*/) public override {
        lastSpender = address(0);
        lastWasSpenderOverload = false;
        callCount += 1;
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
}
