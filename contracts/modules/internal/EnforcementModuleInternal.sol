//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import "../AuthorizationModule.sol";

/**
 * @dev Enforcement module.
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract EnforcementModuleInternal is
    Initializable,
    ContextUpgradeable,
    ERC20Upgradeable
{
    /**
     * @dev Emitted when an address is frozen.
     */
    event Freeze(address indexed enforcer, address indexed owner);

    /**
     * @dev Emitted when an address is unfrozen.
     */
    event Unfreeze(address indexed enforcer, address indexed owner);

    mapping(address => bool) private _frozen;



    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Enforcement_init() internal onlyInitializing {
        __Context_init_unchained();
        __Enforcement_init_unchained();
    }

    function __Enforcement_init_unchained() internal onlyInitializing {}

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function frozen(address account) public view virtual returns (bool) {
        return _frozen[account];
    }

    /**
     * @dev Freezes an address.
     *
     */
    function _freeze(address account) internal virtual returns (bool) {
        if (_frozen[account]) return false;
        _frozen[account] = true;
        emit Freeze(_msgSender(), account);
        return true;
    }

    /**
     * @dev Unfreezes an address.
     *
     */
    function _unfreeze(address account) internal virtual returns (bool) {
        if (!_frozen[account]) return false;
        _frozen[account] = false;
        emit Unfreeze(_msgSender(), account);
        return true;
    }

    uint256[50] private __gap;
}
