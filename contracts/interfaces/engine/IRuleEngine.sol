// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404Extend} from "../tokenization/draft-IERC1404.sol";
import {IERC3643IComplianceContract} from "../tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "../tokenization/draft-IERC7551.sol";

/*
* @title Minimum interface to define a RuleEngine
*/
interface IRuleEngine is IERC1404Extend, IERC7551Compliance,  IERC3643IComplianceContract {
    /**
     *  @notice
     *  Function called whenever tokens are transferred from one wallet to another
     *  @dev 
     *  Must revert if the transfer is invalid
     *  Same name as ERC-3643 but with one supplementary argument `spender`
     *  This function can be used to update state variables of the RuleEngine contract
     *  This function can be called ONLY by the token contract bound to the RuleEngine
     *  @param spender spender address (sender)
     *  @param from token holder address
     *  @param to receiver address
     *  @param value value of tokens involved in the transfer
     */
    function transferred(address spender, address from, address to, uint256 value) external;
}
