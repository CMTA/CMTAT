//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

abstract contract OnlyDelegateCallModule {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable self = address(this);

    function checkDelegateCall() private view {
        require(address(this) != self, "Direct call to the implementation not allowed");
    }

    modifier onlyDelegateCall(bool deployedWithProxy) {
        if(deployedWithProxy){
            checkDelegateCall();
        }
        _;
    }
}