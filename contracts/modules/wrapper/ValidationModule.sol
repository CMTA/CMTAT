//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "./AuthorizationModule.sol";
import "../internal/ValidationModuleInternal.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ValidationModule is ValidationModuleInternal, AuthorizationModule {
        function setRuleEngine(IRuleEngine ruleEngine_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        ruleEngine = ruleEngine_;
        emit RuleEngineSet(address(ruleEngine_));
    }
}
