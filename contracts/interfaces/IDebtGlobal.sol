//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;


interface IDebtGlobal {

    struct DebtBase {
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

    struct CreditEvents {
        bool flagDefault;
        bool flagRedeemed;
        string rating;
    }
    
}