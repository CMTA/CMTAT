//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "./IRule.sol";
import {IRuleEngine} from "../../../interfaces/engine/IRuleEngine.sol";

interface IRuleEngineMock is IRuleEngine {
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
