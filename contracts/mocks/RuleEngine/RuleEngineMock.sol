//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "./interfaces/IRule.sol";
import {IRuleEngineMock} from "./interfaces/IRuleEngineMock.sol";
import {RuleMock} from "./RuleMock.sol";

/*
* @title a RuleEngine mock for testing, not suitable for production
*/
contract RuleEngineMock is IRuleEngineMock {
    IRule[] internal _rules;

    constructor() {
        _rules.push(new RuleMock());
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
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (uint8) {
        uint256 ruleArrayLength = _rules.length;
        for (uint256 i; i < ruleArrayLength; ) {
            uint8 restriction = _rules[i].detectTransferRestriction(
                _from,
                _to,
                _amount
            );
            if (restriction != uint8(REJECTED_CODE_BASE.TRANSFER_OK)) {
                return restriction;
            }
            unchecked {
                ++i;
            }
        }
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public view override returns (bool) {
        return detectTransferRestriction(_from, _to, _amount) == 0;
    }

    /*
    * @dev 
    * Warning: if you want to use this mock, you have to restrict the access to this function through an an access control
    */
    function operateOnTransfer(  address _from,
        address _to,
        uint256 _amount) view public override returns (bool){
        return validateTransfer(_from, _to, _amount);
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
        return "Unknown restriction code";
    }
}
