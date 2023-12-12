//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../interfaces/draft-IERC1404/draft-IERC1404Wrapper.sol";
import "../../interfaces/engine/IRuleEngine.sol";
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
    event RuleEngine(IRuleEngine indexed newRuleEngine);

    IRuleEngine public ruleEngine;

    function __Validation_init_unchained(
        IRuleEngine ruleEngine_
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

    function _operateOnTransfer(address from, address to, uint256 amount) virtual internal returns (bool) {
        return ruleEngine.operateOnTransfer(from, to, amount);
    }

    uint256[50] private __gap;
}
