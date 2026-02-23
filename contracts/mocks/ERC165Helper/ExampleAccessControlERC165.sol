// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

/// @notice ERC-165 interface for AccessControlUpgradeable 
interface IAccessControlUpgradeable165 {
    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;
}


contract ExampleAccessControlUpgradeable165  {
    /// @notice ERC-165 interface detection
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        returns (bool)
    {
        return
            interfaceId == type(IAccessControlUpgradeable165).interfaceId;
    }

    /// @notice Helper function to expose interface IDs (optional)
    function getInterfaceId() external pure returns (bytes4) {
        return type(IAccessControlUpgradeable165).interfaceId;
    }
}