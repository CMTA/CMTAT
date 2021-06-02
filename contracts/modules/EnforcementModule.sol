pragma solidity ^0.8.2;

import "../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";

/**
 * @dev Force transfer module.
 *
 * Useful for to force transfer of tokens by an authorized user
 */
abstract contract EnforcementModule is Initializable, ContextUpgradeable, ERC20Upgradeable {
    /**
     * @dev Emitted when a transfer is forced.
     */
    event Enforcement (address indexed enforcer, address indexed owner, uint amount, string reason);

    /**
     * @dev Emitted when an address is frozen.
     */
    event Freeze (address indexed enforcer, address indexed owner);

    /**
     * @dev Emitted when an address is unfrozen.
     */
    event Unfreeze (address indexed enforcer, address indexed owner);

    mapping(address => bool) private _frozen;

    bytes32 public constant ENFORCER_ROLE = keccak256("ENFORCER_ROLE");
    uint8 internal constant TRANSFER_REJECTED_FROZEN = 2;
    string internal constant TEXT_TRANSFER_REJECTED_FROZEN = "All transfers paused";

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Enforcement_init() internal initializer {
        __Context_init_unchained();
        __Enforcement_init_unchained();
    }

    function __Enforcement_init_unchained() internal initializer {
    }

        /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function frozen(address account) public view virtual returns (bool) {
        return _frozen[account];
    }


    /**
     * @dev Triggers a forced transfer.
     *
     */
    function _enforceTransfer(address owner, address destination, uint amount, string memory reason) internal virtual {
        _transfer(owner, destination, amount);
        emit Enforcement(_msgSender(), owner, amount, reason);
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