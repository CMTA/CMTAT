// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

interface IERC1404ExtendERC165 {
    function detectTransferRestrictionFrom(
        address spender,
        address from,
        address to,
        uint256 value
    ) external view returns (uint8);
    
    /**
     * @notice Returns a uint8 code to indicate if a transfer is restricted or not
     * @dev 
     * See {ERC-1404}
     * This function is where an issuer enforces the restriction logic of their token transfers. 
     * Some examples of this might include:
     * - checking if the token recipient is whitelisted, 
     * - checking if a sender's tokens are frozen in a lock-up period, etc.
     * @param from The address sending tokens.
     * @param to The address receiving tokens.
     * @param value amount of tokens to transfer
     * @return uint8 restricted code, 0 means the transfer is authorized
     *
     */
    function detectTransferRestriction(
        address from,
        address to,
        uint256 value
    ) external view returns (uint8);


    /**
     * @dev See {ERC-1404}
     * This function is effectively an accessor for the "message", 
     * a human-readable explanation as to why a transaction is restricted. 
     *
     */
    function messageForTransferRestriction(
        uint8 restrictionCode
    ) external view returns (string memory);
}

contract ExampleERC1404ExtendERC165  {
    /// @notice ERC-165 interface detection
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        returns (bool)
    {
        return
            interfaceId == type(IERC1404ExtendERC165).interfaceId;
    }

    /// @notice Helper function to expose interface IDs (optional)
    function getInterfaceId() external pure returns (bytes4) {
        return type(IERC1404ExtendERC165).interfaceId;
    }
}