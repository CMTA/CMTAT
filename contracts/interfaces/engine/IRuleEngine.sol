// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404} from "../tokenization/draft-IERC1404.sol";
import {IERC3643ComplianceRead} from "../tokenization/IERC3643Partial.sol";
import {IERC7551Compliance} from "../tokenization/draft-IERC7551.sol";

/*
* @dev minimum interface to define a RuleEngine
*/
interface IRuleEngine is IERC1404, IERC3643ComplianceRead, IERC7551Compliance {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
     */
    function canTransfer(address from, address to, uint256 value) 
    external override(IERC3643ComplianceRead, IERC7551Compliance) 
    view returns (bool);

    /*
     /**
     * @dev Returns true if the transfer is valid, and false otherwise.
     * Same name as ERC-3643 but with one supplementary argument `spender`
     * 
     */
    function transferred(address spender, address from, address to, uint256 value) external returns (bool isValid);

    function transferred(address from, address to, uint256 value) external returns (bool isValid);
}
