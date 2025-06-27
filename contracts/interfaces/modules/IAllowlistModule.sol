
//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @title Allowlist Module Interface
* @notice Manage an allowlist (whitelist)
* 
*/
interface IAllowlistModule {
    /* ============ Events ============ */
    /**
     * @notice Emitted when an address is added to or removed from the allowlist
     * @param account The address whose status was changed
     * @param status True if added to the allowlist, false if removed
     * @param enforcer The address that performed the action
     * @param data Optional additional data
     */
    event AddressAddedToAllowlist(address indexed account, bool indexed status, address indexed enforcer, bytes data);
    /**
     * @notice Emitted when the allowlist is enabled or disabled
     * @param operator The address that changed the status
     * @param status True if enabled, false if disabled
     */
    event AllowlistEnableStatus(address indexed operator, bool status);
    /* ============ Functions ============ */
    /**
     * @notice Checks if an account is allowlisted
     * @param account The address to check
     * @return True if the address is on the allowlist, false otherwise
     */
    function isAllowlisted(address account) external view returns (bool);
    /**
     * @notice Adds or removes an address from the allowlist
     * @param account The address whose status will be changed
     * @param status True to add to the allowlist, false to remove
     */
    function setAddressAllowlist(address account, bool status) external;

    /**
     * @notice Adds or removes an address from the allowlist with additional data
     * @param account The address whose status will be changed
     * @param status True to add to the allowlist, false to remove
     * @param data Additional data for the operation
     */
    function setAddressAllowlist(address account, bool status, bytes calldata data) external;
    /**
    * @notice Batch version of {setAddressAllowlist}
    * @param accounts The list of addresses to update the allowlist status
    * @param status The corresponding list of statuses (true to add, false to remove)
    */
    function batchSetAddressAllowlist(address[] calldata accounts, bool[] calldata status) external;
    /**
     * @notice Enables or disables the allowlist
     * @param status True to enable, false to disable
     */
    function enableAllowlist(bool status) external;
    
    /**
     * @notice Returns whether the allowlist is currently enabled
     * @return True if the allowlist is enabled, false otherwise
     */
    function isAllowlistEnabled() external view returns (bool);
}


