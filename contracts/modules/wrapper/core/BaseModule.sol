//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Tokenization === */
import {IERC3643Base} from "../../../interfaces/tokenization/IERC3643Partial.sol";
abstract contract BaseModule is IERC3643Base {
    /* ============ State Variables ============ */
    /** 
    * @notice 
    * Get the current version of the smart contract
    */
    string private constant VERSION = "3.0.0";
    /* ============ Events ============ */
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @notice ERC-3643 version function
    */
    function version() public view virtual override(IERC3643Base) returns (string memory) {
       return VERSION;
    }
}
