//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;


interface IDebt {
    /* Variables */
    struct Debt {
        uint256 interestRate;
        uint256 parValue;
        string guarantor;
        string bondHolder;
        string maturityDate;
        string interestScheduleFormat;
        string interestPaymentDate;
        string dayCountConvention;
        string businessDayConvention;
        string publicHolidayCalendar;
    }
}