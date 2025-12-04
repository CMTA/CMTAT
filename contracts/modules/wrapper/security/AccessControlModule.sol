//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

abstract contract AccessControlModule is AccessControlUpgradeable {
    error CMTAT_AccessControlModule_AddressZeroNotAllowed();

    /* ============  Initializer Function ============ */
    /**
    * @notice Internal initializer that sets the provided address as the default admin.
    * @dev
    *  - MUST be called only during initialization (`onlyInitializing`).
    *  - Reverts if `admin` is the zero address.
    *  - Grants `DEFAULT_ADMIN_ROLE` to `admin`.  
    *    The return value of `_grantRole` is intentionally ignored, as it returns `false`
    *    only when the role was already assigned.
    *
    * @param admin The address that will receive the `DEFAULT_ADMIN_ROLE`.
    */
    function __AccessControlModule_init_unchained(address admin)
    internal onlyInitializing {
        if(admin == address(0)){
            revert CMTAT_AccessControlModule_AddressZeroNotAllowed();
        }
        // we don't check the return value
        // _grantRole attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
        // return false only if the admin has already the role
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /** 
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable) returns (bool) {
        // The Default Admin has all roles
        if (AccessControlUpgradeable.hasRole(DEFAULT_ADMIN_ROLE, account)) {
            return true;
        } else {
            return AccessControlUpgradeable.hasRole(role, account);
        }
    }
}
