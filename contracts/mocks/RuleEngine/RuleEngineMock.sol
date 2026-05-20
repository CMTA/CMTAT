//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "./interfaces/IRule.sol";
import {IRuleEngineMock} from "./interfaces/IRuleEngineMock.sol";
import {RuleMock} from "./RuleMock.sol";
import {RuleMockMint} from "./RuleMockMint.sol";
import {RuleSpenderAuthorized} from "./RuleSpenderAuthorized.sol";
import {ERC165, IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {RuleEngineInterfaceId} from "../../library/RuleEngineInterfaceId.sol";
import {ERC1404ExtendInterfaceId} from "../../library/ERC1404ExtendInterfaceId.sol";
/*
* @title a RuleEngine mock for testing, not suitable for production
*/
contract RuleEngineMock is ERC165, IRuleEngineMock {
    IRule[] internal _rules;
    error RuleEngine_InvalidTransfer(address from, address to, uint256 value);

    constructor(address spender) {
        _rules.push(new RuleMock());
        _rules.push(new RuleMockMint());
        _rules.push(new RuleSpenderAuthorized(spender));
    }

    /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function setRules(IRule[] calldata rules_) external override {
        _rules = rules_;
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
        uint256 value) view public override{
        require(canTransferFrom(spender, from, to, value), RuleEngine_InvalidTransfer(from, to, value));
    }

    function transferred( 
        address from,
        address to,
        uint256 value) view public override {
        require(canTransfer(from, to, value), RuleEngine_InvalidTransfer(from, to, value));
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

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID || interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID || super.supportsInterface(interfaceId);
    }

    function returnInterfaceId() public pure returns (bytes4) {
        return RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID;
    }
}
