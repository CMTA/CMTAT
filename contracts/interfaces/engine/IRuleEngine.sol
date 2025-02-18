// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404} from "../draft-IERC1404.sol";
import {IERC3643Compliance} from "../IERC3643Partial.sol";

/*
* @dev minimum interface to define a RuleEngine
*/
interface IRuleEngine is IERC1404, IERC3643Compliance {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
     */
    function operateOnTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool isValid);
   
}
