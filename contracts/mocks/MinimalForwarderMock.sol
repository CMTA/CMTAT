//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../openzeppelin-contracts-upgradeable/contracts/metatx/ERC2771ForwarderUpgradeable.sol";

contract MinimalForwarderMock is ERC2771ForwarderUpgradeable {
    function initialize(string memory name) public initializer {
        __EIP712_init_unchained(name, "1");
        __ERC2771Forwarder_init_unchained("");
    }
}
