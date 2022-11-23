pragma solidity ^0.8.2;

abstract contract OnlyDelegateCall {
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable self = address(this);

    function checkDelegateCall() private view {
        require(address(this) != self, "Direct call to the implementation not allowed");
    }

    modifier onlyDelegateCall() {
        checkDelegateCall();
        _;
    }
}