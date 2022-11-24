//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "./AuthorizationModule.sol";
import "../internal/ValidationModuleInternal.sol";
import "./PauseModule.sol";
import "./EnforcementModule.sol";

/**
 * @dev Validation module.
 *
 * Useful for to restrict and validate transfers
 */
abstract contract ValidationModule is ValidationModuleInternal, PauseModule, EnforcementModule, IERC1404Wrapper {
    enum REJECTED_CODE { TRANSFER_OK, TRANSFER_REJECTED_PAUSED, TRANSFER_REJECTED_FROZEN }
    string constant TEXT_TRANSFER_OK = "No restriction";

    function setRuleEngine(IRuleEngine ruleEngine_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        ruleEngine = ruleEngine_;
        emit RuleEngineSet(address(ruleEngine_));
    }

    /**
     * @dev ERC1404 check if _value token can be transferred from _from to _to
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param amount uint256 the amount of tokens to be transferred
     * @return code of the rejection reason
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 amount
    ) public view override returns (uint8 code) {
        if (paused()) {
            return uint8(REJECTED_CODE.TRANSFER_REJECTED_PAUSED);
        } else if (frozen(from)) {
            return uint8(REJECTED_CODE.TRANSFER_REJECTED_FROZEN);
        } else if (address(ruleEngine) != address(0)) {
            return _detectTransferRestriction(from, to, amount);
        }
        return uint8(REJECTED_CODE.TRANSFER_OK);
    }

    /**
     * @dev ERC1404 returns the human readable explaination corresponding to the error code returned by detectTransferRestriction
     * @param restrictionCode The error code returned by detectTransferRestriction
     * @return message The human readable explaination corresponding to the error code returned by detectTransferRestriction
     */
    function messageForTransferRestriction(uint8 restrictionCode)
        external
        view
        override
        returns (string memory message)
    {
        if (restrictionCode == uint8(REJECTED_CODE.TRANSFER_OK)) {
            return TEXT_TRANSFER_OK;
        } else if (restrictionCode == uint8(REJECTED_CODE.TRANSFER_REJECTED_PAUSED)) {
            return TEXT_TRANSFER_REJECTED_PAUSED;
        } else if (restrictionCode == uint8(REJECTED_CODE.TRANSFER_REJECTED_FROZEN)) {
            return TEXT_TRANSFER_REJECTED_FROZEN;
        } else if (address(ruleEngine) != address(0)) {
            return _messageForTransferRestriction(restrictionCode);
        }
    }

    function validateTransfer(
        address from,
        address to,
        uint256 amount
    ) public view override returns (bool) {
         if (address(ruleEngine) != address(0)) {
            return _validateTransfer(from, to, amount);    
        }
        return true;
    }
}
