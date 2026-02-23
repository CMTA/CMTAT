// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

interface IRuleEngineERC165 {
    function transferred(address from, address to, uint256 value) external;
    function transferred(address spender, address from, address to, uint256 value) external;
        function canTransferFrom(
        address spender,
        address from,
        address to,
        uint256 value
    )  external view returns (bool);
  
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) external view returns (bool isValid);
}

contract ExampleRuleEngineERC165  {
    /// @notice ERC-165 interface detection
    function supportsInterface(bytes4 interfaceId)
        public
        pure
        returns (bool)
    {
        return
            interfaceId == type(IRuleEngineERC165).interfaceId;
    }

    /// @notice Helper function to expose interface IDs (optional)
    function getInterfaceId() external pure returns (bytes4) {
        return type(IRuleEngineERC165).interfaceId;
    }
}