//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;


import "../../interfaces/ICMTATConstructor.sol";

/**
* @notice List of Invariant (struct, constant, events)
* 
*/
abstract contract CMTATFactoryInvariant {
    /* ============ Structs ============ */
    struct CMTAT_ARGUMENT{
        address CMTATAdmin;
        ICMTATConstructor.ERC20Attributes ERC20Attributes;
        ICMTATConstructor.BaseModuleAttributes baseModuleAttributes;
        ICMTATConstructor.Engine engines;
    }
    /* ============ State Variables ============ */
    /// @dev Role to deploy CMTAT
    bytes32 public constant CMTAT_DEPLOYER_ROLE = keccak256("CMTAT_DEPLOYER_ROLE");
    /* ============ Events ============ */
    event CMTAT(address indexed CMTAT, uint256 id);
}