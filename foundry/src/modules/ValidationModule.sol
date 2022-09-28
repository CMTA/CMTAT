//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../interfaces/IRuleEngine.sol";


/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when a rule engine is set.
     */
    event RuleEngineSet (address indexed newRuleEngine);

    IRuleEngine public ruleEngine;

    /**
     * @dev Initializes the contract with rule engine.
     */
    function __Validation_init(IRuleEngine ruleEngine_) internal initializer {
        __Context_init_unchained();
        __Validation_init_unchained(ruleEngine_);
    }

    function __Validation_init_unchained(IRuleEngine ruleEngine_) internal initializer {
        if (address(ruleEngine_) != address(0)) {
            ruleEngine = ruleEngine_;
            emit RuleEngineSet(address(ruleEngine));
        }
    }

    function _validateTransfer(address from, address to, uint256 amount) internal view returns (bool) {
        return ruleEngine.validateTransfer(from, to, amount);
    }

    function _messageForTransferRestriction(uint8 restrictionCode) internal view returns (string memory) {
        return ruleEngine.messageForTransferRestriction(restrictionCode);
    }

    function _detectTransferRestriction(address from, address to, uint256 amount) internal view returns (uint8) {
        return ruleEngine.detectTransferRestriction(from, to, amount);
    }

    uint256[50] private __gap;
}