// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {IERC1404Wrapper} from "../draft-IERC1404/draft-IERC1404Wrapper.sol";

/*
* @dev minimum interface to define a RuleEngine
*/
interface IRuleEngine is IERC1404Wrapper {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
     */
    function operateOnTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool isValid);
   
}
