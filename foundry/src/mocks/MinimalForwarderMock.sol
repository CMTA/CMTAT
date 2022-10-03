//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.2;

import "openzeppelin-contracts-upgradeable/contracts/metatx/MinimalForwarderUpgradeable.sol";

contract MinimalForwarderMock is MinimalForwarderUpgradeable {
  function initialize() public initializer {
    __MinimalForwarder_init();
  }
}
