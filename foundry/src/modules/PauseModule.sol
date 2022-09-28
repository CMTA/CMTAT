//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract PauseModule is Initializable, PausableUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint8 internal constant TRANSFER_REJECTED_PAUSED = 1;
    string internal constant TEXT_TRANSFER_REJECTED_PAUSED = "All transfers paused";
}
