// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.0;

import "../draft-IERC1404/draft-IERC1404Wrapper.sol";

interface IRuleEngineCMTAT is IERC1404Wrapper {
    /**
     * @dev Returns true if the operation is a success, and false otherwise.
     */
    function operateOnTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external returns (bool isValid);
   
}
