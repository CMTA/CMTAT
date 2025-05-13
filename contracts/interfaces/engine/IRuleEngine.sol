// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404} from "../tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead} from "../tokenization/IERC3643Partial.sol";

/*
* @dev minimum interface to define a RuleEngine
*/
interface IRuleEngine is IERC1404, IERC3643ComplianceRead {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
     */
    function canTransferFrom(
       address spender, address from, address to, uint256 value
    ) external view returns (bool isValid);

    /*
     /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     * Same name as ERC-3643 but with one supplementary argument `spender`
     * 
     */
    function transferred(address spender, address from, address to, uint256 value) external returns (bool isValid);
   
}
