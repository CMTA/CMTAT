//SPDX-License-Identifier: MPL-2.0

import {IERC1643} from "./engine/draft-IERC1643.sol";
pragma solidity ^0.8.20;

interface IERC1643CMTAT {
    struct DocumentInfo {
        string name;
        string uri;
        bytes32 documentHash;
 }
}
 