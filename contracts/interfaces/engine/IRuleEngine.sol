// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404} from "../draft-IERC1404.sol";
import {IERC3643ComplianceRead, IERC3643ComplianceWrite} from "../IERC3643Partial.sol";

/*
* @dev minimum interface to define a RuleEngine
*/
interface IRuleEngine is IERC1404, IERC3643ComplianceRead, IERC3643ComplianceWrite {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
     */
    function canApprove(
        address owner,
        address spender,
        uint256 value
    ) external view returns (bool isValid);
   
}
