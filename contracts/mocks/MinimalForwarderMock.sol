//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {ERC2771ForwarderUpgradeable} from "@openzeppelin/contracts-upgradeable/metatx/ERC2771ForwarderUpgradeable.sol";


/*
* @title a MinimalForwarderMock for testing, not suitable for production
*/
contract MinimalForwarderMock is ERC2771ForwarderUpgradeable {
}