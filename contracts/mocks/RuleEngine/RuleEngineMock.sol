//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "./interfaces/IRule.sol";
import {IRuleEngineMock} from "./interfaces/IRuleEngineMock.sol";
import {RuleMock} from "./RuleMock.sol";
import {RuleMockMint} from "./RuleMockMint.sol";
import {RuleSpenderAuthorized} from "./RuleSpenderAuthorized.sol";
import {RuleTokenHolderTracker} from "./RuleTokenHolderTracker.sol";
import {IRuleTransferHook} from "./interfaces/IRuleTransferHook.sol";
import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC1404} from "../../interfaces/tokenization/draft-IERC1404.sol";
import {RuleEngineInterfaceId} from "../../library/RuleEngineInterfaceId.sol";
import {ERC1404ExtendInterfaceId} from "../../library/ERC1404ExtendInterfaceId.sol";
/*
* @title a RuleEngine mock for testing, not suitable for production
*/
contract RuleEngineMock is ERC165, IRuleEngineMock {
    IRule[] internal _rules;
    address private _holderTrackerRule;
    error RuleEngine_InvalidTransfer(address from, address to, uint256 value);

    constructor(address spender) {
        _rules.push(new RuleMock());
        _rules.push(new RuleMockMint());
        _rules.push(new RuleSpenderAuthorized(spender));
        RuleTokenHolderTracker holderTrackerRuleInstance = new RuleTokenHolderTracker();
        _rules.push(holderTrackerRuleInstance);
        _holderTrackerRule = address(holderTrackerRuleInstance);
    }

    /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function setRules(IRule[] calldata rules_) external override {
        _rules = rules_;
        _holderTrackerRule = address(0);
        uint256 rulesLength = _rules.length;
        for (uint256 i = 0; i < rulesLength; ++i) {
            try IRuleTransferHook(address(_rules[i])).transferred(address(0), address(0), address(0), 0) {
                _holderTrackerRule = address(_rules[i]);
                break;
            } catch {
                continue;
            }
        }
    }

    function rulesCount() external view override returns (uint256) {
        return _rules.length;
    }

    function rule(uint256 ruleId) external view override returns (IRule) {
        return _rules[ruleId];
    }

    function rules() external view override returns (IRule[] memory) {
        return _rules;
    }

    function detectTransferRestriction(
       address from,
        address to,
        uint256 value
    ) public view override returns (uint8) {
        uint256 ruleArrayLength = _rules.length;
        for (uint256 i = 0; i < ruleArrayLength; ++i) {
            uint8 restriction = _rules[i].detectTransferRestriction(
               from,
               to, 
               value
            );
            if (restriction != uint8(REJECTED_CODE_BASE.TRANSFER_OK)) {
                return restriction;
            }
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }


    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view override returns (uint8) {
        uint256 ruleArrayLength = _rules.length;
        for (uint256 i = 0; i < ruleArrayLength; ++i) {
            uint8 restriction = _rules[i].detectTransferRestrictionFrom(
               spender,
               from,
               to, 
               value
            );
            if (restriction != uint8(REJECTED_CODE_BASE.TRANSFER_OK)) {
                return restriction;
            }
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }


    function canTransfer(
        address from,
        address to,
        uint256 value
    ) public view override returns (bool) {
        return detectTransferRestriction(from, to, value) == 0;
    }

    function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) public view override returns (bool) {
        return detectTransferRestrictionFrom(spender, from, to, value) == 0;
    }

    /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function transferred(
        address spender,
        address from,
        address to,
        uint256 value) public override{
        require(canTransferFrom(spender, from, to, value), RuleEngine_InvalidTransfer(from, to, value));
        _callRuleHooks(spender, from, to, value);
    }

    function transferred(
        address from,
        address to,
        uint256 value) public override {
        require(canTransfer(from, to, value), RuleEngine_InvalidTransfer(from, to, value));
        _callRuleHooks(address(0), from, to, value);
    }

    function holderTrackerRule() external view returns (address) {
        return _holderTrackerRule;
    }

    /**
    * @dev
    * For all the rules, each restriction code has to be unique.
    */
    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) public view override returns (string memory) {
        uint256 ruleArrayLength = _rules.length;
        for (uint256 i; i < ruleArrayLength; ) {
            if (_rules[i].canReturnTransferRestrictionCode(_restrictionCode)) {
                return
                    _rules[i].messageForTransferRestriction(_restrictionCode);
            }
            unchecked {
                ++i;
            }
        }
        return "UnknownRestrictionCode";
    }

    /**
    * @dev advertises support for both the mandatory ERC-1404 interface
    * (`IERC1404`, id `0xab84a5c8`) and its spender-aware extension
    * (`IERC1404Extend`, id `0x78a8de7d`), as required by the ERC-1404 rework:
    * an implementation exposing the extension must still return true for the
    * mandatory id so a base-only integrator continues to detect it.
    * @dev The extension id is taken from {ERC1404ExtendInterfaceId} because
    * Solidity's `type(IERC1404Extend).interfaceId` excludes inherited functions
    * and would therefore only cover `detectTransferRestrictionFrom`.
    */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1404).interfaceId || interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID || interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID || super.supportsInterface(interfaceId);
    }

    function returnInterfaceId() public pure returns (bytes4) {
        return RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID;
    }

    function _callRuleHooks(address spender, address from, address to, uint256 value) internal {
        uint256 ruleArrayLength = _rules.length;
        for (uint256 i = 0; i < ruleArrayLength; ++i) {
            try IRuleTransferHook(address(_rules[i])).transferred(spender, from, to, value) {} catch {}
        }
    }
}
