//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "./IRule.sol";
import "./IRuleCommon.sol";

interface IRuleEngine is IRuleCommon{
    function setRules(IRule[] calldata rules_) external;

    function ruleLength() external view returns (uint256);

    function rule(uint256 ruleId) external view returns (IRule);

    function rules() external view returns (IRule[] memory);

    function addRule(IRule rule_) external;
     
    function addRules(IRule[] calldata rules_) external;
}
