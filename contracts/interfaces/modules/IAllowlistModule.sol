
//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/*
* @title Allowlist
* @notice Manage an allowlist (whitelist)
* 
*/
interface IAllowlistModule {
    /* ============ Events ============ */
    /**
    * @notice Emitted when an address is added to the allowlist
    */
    event AddressAddedToAllowlist(address indexed account, bool indexed status, address indexed enforcer, bytes data);
    /**
    * @notice Emitted the allowlist is enabled & disabled
    */
    event AllowlistEnableStatus(address indexed operator, bool status);
    /* ============ Functions ============ */
    /**
    * @notice return true if `account`is in the allowlist, false otherwise
    */
    function isAllowlisted(address account) external view returns (bool);
    /**
     * @notice add/remove an address to/from the allowlist
     * @param account the account to add
     * @param status true to add to the allowlist, false to remove
     */
    function setAddressAllowlist(address account, bool status) external;

    /**
     * @notice add/remove an address to/from the allowlist
     * @param account the account to add
     * @param status true to add to the allowlist, false to remove
     * @param data further information if needed
     */
    function setAddressAllowlist(address account, bool status, bytes calldata data) external;
    /**
    * @notice Batch version of {setAddressAllowlist}
    */
    function batchSetAddressAllowlist(address[] calldata accounts, bool[] calldata status) external;
    /**
    * @notice enable/disable allowlist
    */
    function enableAllowlist(bool status) external;
    
    /**
    * @notice Returns true if the list is enabled, false otherwise
    */
    function isAllowlistEnabled() external view returns (bool);
}


