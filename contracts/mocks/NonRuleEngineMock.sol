// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.24;

/// @dev Contract-shaped address that intentionally does not implement IRuleEngine.
contract NonRuleEngineMock {
    function ping() external pure returns (uint256) {
        return 1;
    }
}
