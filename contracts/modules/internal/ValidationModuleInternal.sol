//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../interfaces/IEIP1404/IEIP1404Wrapper.sol";

/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModuleInternal is
    Initializable,
    ContextUpgradeable
{
    /**
     * @dev Emitted when a rule engine is set.
     */
    event RuleEngine(IEIP1404Wrapper indexed newRuleEngine);

    IEIP1404Wrapper public ruleEngine;

    /**
     * @dev Initializes the contract with rule engine.
     */
    function __Validation_init(
        IEIP1404Wrapper ruleEngine_
    ) internal onlyInitializing {
        __Context_init_unchained();
        __Validation_init_unchained(ruleEngine_);
    }

    function __Validation_init_unchained(
        IEIP1404Wrapper ruleEngine_
    ) internal onlyInitializing {
        if (address(ruleEngine_) != address(0)) {
            ruleEngine = ruleEngine_;
            emit RuleEngine(ruleEngine);
        }
    }

    /**
    @dev before making a call to this function, you have to check if a ruleEngine is set.
    */
    function _validateTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view returns (bool) {
        return ruleEngine.validateTransfer(from, to, amount);
    }

    /**
    @dev before making a call to this function, you have to check if a ruleEngine is set.
    */
    function _messageForTransferRestriction(
        uint8 restrictionCode
    ) internal view returns (string memory) {
        return ruleEngine.messageForTransferRestriction(restrictionCode);
    }

    /**
    @dev before making a call to this function, you have to check if a ruleEngine is set.
    */
    function _detectTransferRestriction(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint8) {
        return ruleEngine.detectTransferRestriction(from, to, amount);
    }

    uint256[50] private __gap;
}
