//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

import {IRule} from "./IRule.sol";
import {IRuleEngineERC1404} from "../../../interfaces/engine/IRuleEngine.sol";

interface IRuleEngineMock is IRuleEngineERC1404 {
    /**
     * @dev define the rules, the precedent rules will be overwritten
     */
    function setRules(IRule[] calldata rules_) external;

    /**
     * @dev return the number of rules
     * @return The number of rules currently configured.
     */
    function rulesCount() external view returns (uint256);

    /**
     * @dev return the rule at the index specified by ruleId
     * @return The rule stored at index `ruleId`.
     */
    function rule(uint256 ruleId) external view returns (IRule);

    /**
     * @dev return all the rules
     * @return The list of all configured rules.
     */
    function rules() external view returns (IRule[] memory);
}
