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

  function detectTransferRestriction(
    address _from,
    address _to,
    uint256 _amount)
  public view returns (uint8)
  {
    for (uint256 i = 0; i < _rules.length; i++) {
      uint8 restriction = _rules[i].detectTransferRestriction(_from, _to, _amount);
      if (restriction > 0) {
        return restriction;
      }
    }
    return 0;
  }

  function validateTransfer(
    address _from,
    address _to,
    uint256 _amount)
  public view returns (bool)
  {
    return detectTransferRestriction(_from, _to, _amount) == 0;
  }

  function messageForTransferRestriction(uint8 _restrictionCode) public view returns (string memory) {
    for (uint256 i = 0; i < _rules.length; i++) {
      if (_rules[i].canReturnTransferRestrictionCode(_restrictionCode)) {
        return _rules[i].messageForTransferRestriction(_restrictionCode);
      }
    }
    return "Unknown restriction code";
  }
}
