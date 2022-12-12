//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "./AuthorizationModule.sol";
import "../internal/SnapshotModuleInternal.sol";

/**
 * @dev Snapshot module.
 *
 * Useful to take a snapshot of token holder balance and total supply at a specific time
 */
abstract contract SnasphotModule is SnapshotModuleInternal, AuthorizationModule {
    bytes32 public constant SNAPSHOOTER_ROLE = keccak256("SNAPSHOOTER_ROLE");

    function __SnasphotModule_init(string memory name_, string memory symbol_) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();
        // SnapshotModuelInternal inherits from ERC20
        __ERC20_init_unchained(name_, symbol_);
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();

        /* Internal */
        __Snapshot_init_unchained();

        /* Wrapper */
        __AuthorizationModule_init_unchained();

        /* own function */
        __SnasphotModule_init_unchained();

    }

    function __SnasphotModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

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

    uint256[50] private __gap;
}
