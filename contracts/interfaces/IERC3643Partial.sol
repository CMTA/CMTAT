//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/**
* @dev interface with common functions between CMTAT and ERC3643
* Note that argument name can change compare to ERC3643
*/
interface IERC3643Pause {
    function paused() external view returns (bool);
    function pause() external;
    function unpause() external;
} 
interface IERC3643ERC20Base {
    // setters
    function setName(string calldata _name) external;
    function setSymbol(string calldata _symbol) external;
    // Contrary to ERC-3643 specification, return bool to keep the same behaviour as ERC-20 transfer
    function batchTransfer(address[] calldata tos,uint256[] calldata values) external returns (bool);
}

interface IERC3643Base {
    // getters
    function version() external view returns (string memory);
}

interface IERC3643Enforcement {
    // getters
    function isFrozen(address account) external view returns (bool);

}
interface IERC3643Mint{
    // transfer actions
    function mint(address account, uint256 value) external;
    function batchMint( address[] calldata accounts,uint256[] calldata values) external;
}
interface IERC3643Burn{
    // transfer actions
    function forcedTransfer(address account, address to, uint256 value) external returns (bool);
    function burn(address account,uint256 value) external;
    // batch functions
    function batchBurn(address[] calldata accounts,uint256[] calldata values) external;
}

interface IERC3643ComplianceRead {
    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function canTransfer(
        address from,
        address to,
        uint256 value
    ) external view returns (bool isValid);
}

interface IERC3643ComplianceWrite {
    /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     */
    function transferred(address from, address to, uint256 value) external returns (bool isValid);
}

