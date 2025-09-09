//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Tokenization === */
import {IERC3643Base} from "../../../interfaces/tokenization/IERC3643Partial.sol";
abstract contract BaseModule is IERC3643Base {
    /* ============ State Variables ============ */
    /** 
    * @dev 
    * Get the current version of the smart contract
    */
    string private constant VERSION = "3.1.0";
    /* ============ Events ============ */
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc IERC3643Base
    */
    function version() public view virtual override(IERC3643Base) returns (string memory version_) {
       return VERSION;
    }
}
