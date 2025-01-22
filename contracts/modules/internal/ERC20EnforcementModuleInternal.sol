//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/**
 * @dev Enforcement module.
 *
 * Allows the issuer to freeze transfers from a given address
 */
abstract contract ERC20EnforcementModuleInternal is
    Initializable,
    ContextUpgradeable,
     ERC20Upgradeable
{
    /* ============ Events ============ */
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

    /**
     * @notice Emitted when a transfer is forced.
     */
    event Enforcement (address indexed enforcer, address indexed account, uint256 amount, string reason);

     /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20EnforcementModuleInternal")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20EnforcementModuleInternalStorageLocation = 0x3f8bb8b8091c756b4423e8d10de8c6b7534e765f399b3f3409d2bed57af75e00;
    

    /* ==== ERC-7201 State Variables === */
    struct ERC20EnforcementModuleInternalStorage {
        mapping(address => bool) _frozen;
    }


    /*//////////////////////////////////////////////////////////////
                         INITIALIZER FUNCTION
    //////////////////////////////////////////////////////////////*/
    function __ERC20Enforcement_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Returns true if the account is frozen, and false otherwise.
     */
    function frozen(address account) public view virtual returns (bool) {
        ERC20EnforcementModuleInternalStorage storage $ = _getERC20EnforcementModuleInternalStorage();
        return $._frozen[account];
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

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
        ERC20EnforcementModuleInternalStorage storage $ = _getERC20EnforcementModuleInternalStorage();
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
        ERC20EnforcementModuleInternalStorage storage $ = _getERC20EnforcementModuleInternalStorage();
        if (!$._frozen[account]) {
            return false;
        }
        $._frozen[account] = false;
        emit Unfreeze(_msgSender(), account, reason, reason);

        return true;
    }

    /**
     * @dev Triggers a forced transfer.
     *
     */
    function _enforceTransfer(address account, address destination, uint256 value, string calldata reason) internal virtual {
        _transfer(account, destination, value);
        emit Enforcement(_msgSender(), account, value, reason);
    }

    /* ============ ERC-7201 ============ */
    function _getERC20EnforcementModuleInternalStorage() private pure returns (ERC20EnforcementModuleInternalStorage storage $) {
        assembly {
            $.slot := ERC20EnforcementModuleInternalStorageLocation
        }
    }
}
