// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404Extend} from "../tokenization/draft-IERC1404.sol";
import {IERC3643IComplianceContract} from "../tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "../tokenization/draft-IERC7551.sol";

/*
* @dev minimum interface to define a RuleEngine
*/
interface IRuleEngine is IERC1404Extend, IERC7551Compliance,  IERC3643IComplianceContract {
    /*
     /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     * Same name as ERC-3643 but with one supplementary argument `spender`
     * 
     */
    function transferred(address spender, address from, address to, uint256 value) external;
}
