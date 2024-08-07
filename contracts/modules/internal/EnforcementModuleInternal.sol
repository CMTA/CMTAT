//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";

/**
 * @dev Enforcement module.
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract EnforcementModuleInternal is
    Initializable,
    ContextUpgradeable
{
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.EnforcementModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant EnforcementModuleInternalStorageLocation = 0x0c7bc8a17be064111d299d7669f49519cb26c58611b72d9f6ccc40a1e1184e00;
    
    /**
     * @notice Emitted when an address is frozen.
     */
    event Freeze(
        address indexed enforcer,
        address indexed owner,
        string indexed reasonIndexed,
        string reason
    );

    /**
     * @notice Emitted when an address is unfrozen.
     */
    event Unfreeze(
        address indexed enforcer,
        address indexed owner,
        string indexed reasonIndexed,
        string reason
    );

    /* Variables */
    struct EnforcementModuleInternalStorage {
        mapping(address => bool) _frozen;
    }


    function __Enforcement_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @dev Returns true if the account is frozen, and false otherwise.
     */
    function frozen(address account) public view virtual returns (bool) {
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        return $._frozen[account];
    }

    /**
     * @dev Freezes an address.
     * @param account the account to freeze
     * @param reason indicate why the account was frozen.
     *
     */
    function _freeze(
        address account,
        string calldata reason
    ) internal virtual returns (bool) {
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        if ($._frozen[account]) {
            return false;
        }
        $._frozen[account] = true;
        emit Freeze(_msgSender(), account, reason, reason);
        return true;
    }

    /**
     * @dev Unfreezes an address.
     * @param account the account to unfreeze
     * @param reason indicate why the account was unfrozen.
     */
    function _unfreeze(
        address account,
        string calldata reason
    ) internal virtual returns (bool) {
        EnforcementModuleInternalStorage storage $ = _getEnforcementModuleInternalStorage();
        if (!$._frozen[account]) {
            return false;
        }
        $._frozen[account] = false;
        emit Unfreeze(_msgSender(), account, reason, reason);

        return true;
    }

    function _getEnforcementModuleInternalStorage() private pure returns (EnforcementModuleInternalStorage storage $) {
        assembly {
            $.slot := EnforcementModuleInternalStorageLocation
        }
    }
}
