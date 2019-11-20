/* 
 * Copyright (c) Capital Market and Technology Association, 2018-2019
 * https://cmta.ch
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. 
 */

pragma solidity ^0.5.3;

import "../interface/IRule.sol";
import "../interface/IRuleEngine.sol";
import "./RuleMock.sol";


contract RuleEngineMock is IRuleEngine {
  IRule[] internal _rules;

  constructor() public {
    _rules.push(new RuleMock());
  }

  function setRules(IRule[] calldata rules) external {
    _rules = rules;
  }

  function ruleLength() external view returns (uint256) {
    return _rules.length;
  }

  function rule(uint256 ruleId) external view returns (IRule) {
    return _rules[ruleId];
  }

  function rules() external view returns(IRule[] memory) {
    return _rules;
  }

  function validateTransfer(
    address _from, 
    address _to, 
    uint256 _amount)
  external view returns (bool) 
  {
    for (uint256 i = 0; i < _rules.length; i++) {
      if (!_rules[i].isTransferValid(_from, _to, _amount)) {
        return false;
      }
    }
    return true;
  }
}
