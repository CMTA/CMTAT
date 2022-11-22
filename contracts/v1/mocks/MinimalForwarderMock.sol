pragma solidity ^0.8.2;

import "../../../openzeppelin-contracts-upgradeable/contracts/metatx/MinimalForwarderUpgradeable.sol";

contract MinimalForwarderMockV1 is MinimalForwarderUpgradeable {
  function initialize() public initializer {
    __MinimalForwarder_init();
  }
}
