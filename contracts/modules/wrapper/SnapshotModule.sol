//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../openzeppelin-contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../AuthorizationModule.sol";
import "../internal/SnapshotModuleInternal.sol";
/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract SnasphotModule is SnapshotModuleInternal, AuthorizationModule {
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");

    function scheduleSnapshot(uint256 time)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _scheduleSnapshot(time);
    }

    function rescheduleSnapshot(uint256 oldTime, uint256 newTime)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _rescheduleSnapshot(oldTime, newTime);
    }

    function unscheduleSnapshot(uint256 time)
        public
        onlyRole(SNAPSHOOTER_ROLE)
    {
        _unscheduleSnapshot(time);
    }
}
