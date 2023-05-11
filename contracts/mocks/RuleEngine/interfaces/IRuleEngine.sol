//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;

import "./IRule.sol";
import "../../../interfaces/IEIP1404/IEIP1404Wrapper.sol";

interface IRuleEngine is IEIP1404Wrapper {
    /**
     * @dev define the rules, the precedent rules will be overwritten
     */
    function setRules(IRule[] calldata rules_) external;

    /**
     * @dev return the number of rules
     */
    function rulesCount() external view returns (uint256);

    /**
     * @dev return the rule at the index specified by ruleId
     */
    function rule(uint256 ruleId) external view returns (IRule);

    /**
     * @dev return all the rules
     */
    function rules() external view returns (IRule[] memory);
}
