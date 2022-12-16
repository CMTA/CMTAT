//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;


interface IDebt {
    /* Variables */
    struct Debt {
        string guarantor;
        string bondHolder;
        string maturityDate;
        uint256 interestRate;
        uint256 parValue;
        string interestDetails;
    }
}