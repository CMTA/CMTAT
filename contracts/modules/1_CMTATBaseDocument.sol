// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {DocumentERC1643Module} from "./wrapper/extensions/DocumentERC1643Module.sol";

/**
 * @title Level-1 base with document management
 */
abstract contract CMTATBaseDocument is DocumentERC1643Module {}
