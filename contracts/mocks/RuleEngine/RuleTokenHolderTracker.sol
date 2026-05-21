//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IRule} from "./interfaces/IRule.sol";
import {IRuleTransferHook} from "./interfaces/IRuleTransferHook.sol";
import {CodeList} from "./CodeList.sol";

/**
 * @title Mock stateful rule that tracks token holders through RuleEngine hooks.
 * @dev This rule is permissive (always returns TRANSFER_OK) and only updates storage.
 */
contract RuleTokenHolderTracker is IRule, IRuleTransferHook, CodeList {
    mapping(address => uint256) private _trackedBalance;
    mapping(address => bool) private _isHolder;
    address[] private _holders;
    uint256 private _holdersCount;

    function transferred(address, address from, address to, uint256 value) external override {
        if (from != address(0)) {
            _trackedBalance[from] -= value;
            _updateHolderStatus(from);
        }
        if (to != address(0)) {
            _trackedBalance[to] += value;
            _updateHolderStatus(to);
        }
    }

    function trackedBalance(address account) external view returns (uint256) {
        return _trackedBalance[account];
    }

    function isHolder(address account) external view returns (bool) {
        return _isHolder[account];
    }

    function holdersCount() external view returns (uint256) {
        return _holdersCount;
    }

    function holderAt(uint256 index) external view returns (address) {
        return _holders[index];
    }

    function canTransfer(address, address, uint256) external pure override returns (bool) {
        return true;
    }

    function detectTransferRestriction(address, address, uint256) public pure override returns (uint8) {
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function detectTransferRestrictionFrom(address, address, address, uint256) public pure override returns (uint8) {
        return uint8(REJECTED_CODE_BASE.TRANSFER_OK);
    }

    function canReturnTransferRestrictionCode(uint8) external pure override returns (bool) {
        return false;
    }

    function messageForTransferRestriction(uint8) external pure override returns (string memory) {
        return TEXT_CODE_NOT_FOUND;
    }

    function _updateHolderStatus(address account) private {
        bool shouldBeHolder = _trackedBalance[account] > 0;
        bool current = _isHolder[account];
        if (shouldBeHolder && !current) {
            _isHolder[account] = true;
            _holders.push(account);
            _holdersCount += 1;
        } else if (!shouldBeHolder && current) {
            _isHolder[account] = false;
            _holdersCount -= 1;
        }
    }
}
