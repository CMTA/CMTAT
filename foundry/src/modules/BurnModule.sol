//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";

abstract contract BurnModule is Initializable {
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    event Burn (address indexed owner, uint amount);
}
