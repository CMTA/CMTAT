//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../libraries/Errors.sol";

/**
@dev When a contract is deployed with a proxy, insure that some functions (e.g. delegatecall and selfdestruct) can only be triggered through proxies 
and not on the implementation contract itself.
*/
abstract contract OnlyDelegateCallModule {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable self = address(this);

    function checkDelegateCall() private view {
        if(address(this) == self) revert Errors.DirectCallToImplementation();
    }

    modifier onlyDelegateCall(bool deployedWithProxy) {
        if (deployedWithProxy) {
            checkDelegateCall();
        }
        _;
    }
}
