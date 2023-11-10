//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../../interfaces/IDebtGlobal.sol";
import "../../../security/AuthorizationModule.sol";

import "../../../../libraries/Errors.sol";

abstract contract DebtBaseModule is
    IDebtGlobal,
    Initializable,
    ContextUpgradeable,
    AuthorizationModule
{
    DebtBase public debt;

    /* Events */
    event InterestRate(uint256 newInterestRate);
    event ParValue(uint256 newParValue);
    event Guarantor(string indexed newGuarantorIndexed, string newGuarantor);
    event BondHolder(string indexed newBondHolderIndexed, string newBondHolder);
    event MaturityDate(
        string indexed newMaturityDateIndexed,
        string newMaturityDate
    );
    event InterestScheduleFormat(
        string indexed newInterestScheduleFormatIndexed,
        string newInterestScheduleFormat
    );
    event InterestPaymentDate(
        string indexed newInterestPaymentDateIndexed,
        string newInterestPaymentDate
    );
    event DayCountConvention(
        string indexed newDayCountConventionIndexed,
        string newDayCountConvention
    );
    event BusinessDayConvention(
        string indexed newBusinessDayConventionIndexed,
        string newBusinessDayConvention
    );
    event PublicHolidaysCalendar(
        string indexed newPublicHolidaysCalendarIndexed,
        string newPublicHolidaysCalendar
    );
    event IssuanceDate(
        string indexed newIssuanceDateIndexed,
        string newIssuanceDate
    );
    event CouponFrequency(
        string indexed newCouponFrequencyIndexed,
        string newCouponFrequency
    );

    function __DebtBaseModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /*
    @notice Set all attributes of debt
    The values of all attributes will be changed even if the new values are the same as the current ones
    */
    function setDebt(DebtBase calldata debt_) public onlyRole(DEBT_ROLE) {
        debt = debt_;
        emit InterestRate(debt_.interestRate);
        emit ParValue(debt_.parValue);
        emit Guarantor(debt_.guarantor, debt_.guarantor);
        emit BondHolder(debt_.bondHolder, debt_.bondHolder);
        emit MaturityDate(debt_.maturityDate, debt_.maturityDate);
        emit InterestScheduleFormat(
            debt_.interestScheduleFormat,
            debt_.interestScheduleFormat
        );
        emit InterestPaymentDate(
            debt_.interestPaymentDate,
            debt_.interestPaymentDate
        );
        emit DayCountConvention(
            debt_.dayCountConvention,
            debt_.dayCountConvention
        );
        emit BusinessDayConvention(
            debt_.businessDayConvention,
            debt_.businessDayConvention
        );
        emit PublicHolidaysCalendar(
            debt_.publicHolidaysCalendar,
            debt_.publicHolidaysCalendar
        );

        emit IssuanceDate(debt_.issuanceDate, debt_.issuanceDate);

        emit CouponFrequency(debt_.couponFrequency, debt_.couponFrequency);
    }

    /*
    @notice The call will be reverted if the new value of interestRate is the same as the current one
    */
    function setInterestRate(uint256 interestRate_) public onlyRole(DEBT_ROLE) {
        if (interestRate_ == debt.interestRate) {
            revert Errors.CMTAT_DebtModule_SameValue();
        }
        debt.interestRate = interestRate_;
        emit InterestRate(interestRate_);
    }

    /*
    @notice The call will be reverted if the new value of parValue is the same as the current one
    */
    function setParValue(uint256 parValue_) public onlyRole(DEBT_ROLE) {
        if (parValue_ == debt.parValue) {
            revert Errors.CMTAT_DebtModule_SameValue();
        }
        debt.parValue = parValue_;
        emit ParValue(parValue_);
    }

    /*
    @notice The Guarantor will be changed even if the new value is the same as the current one
    */
    function setGuarantor(
        string calldata guarantor_
    ) public onlyRole(DEBT_ROLE) {
        debt.guarantor = guarantor_;
        emit Guarantor(guarantor_, guarantor_);
    }

    /*
    @notice The bonHolder will be changed even if the new value is the same as the current one
    */
    function setBondHolder(
        string calldata bondHolder_
    ) public onlyRole(DEBT_ROLE) {
        debt.bondHolder = bondHolder_;
        emit BondHolder(bondHolder_, bondHolder_);
    }

    /*
    @notice The maturityDate will be changed even if the new value is the same as the current one
    */
    function setMaturityDate(
        string calldata maturityDate_
    ) public onlyRole(DEBT_ROLE) {
        debt.maturityDate = maturityDate_;
        emit MaturityDate(maturityDate_, maturityDate_);
    }

    /*
    @notice The interestScheduleFormat will be changed even if the new value is the same as the current one
    */
    function setInterestScheduleFormat(
        string calldata interestScheduleFormat_
    ) public onlyRole(DEBT_ROLE) {
        debt.interestScheduleFormat = interestScheduleFormat_;
        emit InterestScheduleFormat(
            interestScheduleFormat_,
            interestScheduleFormat_
        );
    }

    /*
    @notice The interestPaymentDate will be changed even if the new value is the same as the current one
    */
    function setInterestPaymentDate(
        string calldata interestPaymentDate_
    ) public onlyRole(DEBT_ROLE) {
        debt.interestPaymentDate = interestPaymentDate_;
        emit InterestPaymentDate(interestPaymentDate_, interestPaymentDate_);
    }

    /*
    @notice The dayCountConvention will be changed even if the new value is the same as the current one
    */
    function setDayCountConvention(
        string calldata dayCountConvention_
    ) public onlyRole(DEBT_ROLE) {
        debt.dayCountConvention = dayCountConvention_;
        emit DayCountConvention(dayCountConvention_, dayCountConvention_);
    }

    /*
    @notice The businessDayConvention will be changed even if the new value is the same as the current one
    */
    function setBusinessDayConvention(
        string calldata businessDayConvention_
    ) public onlyRole(DEBT_ROLE) {
        debt.businessDayConvention = businessDayConvention_;
        emit BusinessDayConvention(
            businessDayConvention_,
            businessDayConvention_
        );
    }

    /*
    @notice The publicHolidayCalendar will be changed even if the new value is the same as the current one
    */
    function setPublicHolidaysCalendar(
        string calldata publicHolidaysCalendar_
    ) public onlyRole(DEBT_ROLE) {
        debt.publicHolidaysCalendar = publicHolidaysCalendar_;
        emit PublicHolidaysCalendar(
            publicHolidaysCalendar_,
            publicHolidaysCalendar_
        );
    }

    /*
    @notice The issuanceDate will be changed even if the new value is the same as the current one
    */
    function setIssuanceDate(
        string calldata issuanceDate_
    ) public onlyRole(DEBT_ROLE) {
        debt.issuanceDate = issuanceDate_;
        emit IssuanceDate(issuanceDate_, issuanceDate_);
    }

    /*
    @notice The couponFrequency will be changed even if the new value is the same as the current one
    */
    function setCouponFrequency(
        string calldata couponFrequency_
    ) public onlyRole(DEBT_ROLE) {
        debt.couponFrequency = couponFrequency_;
        emit CouponFrequency(couponFrequency_, couponFrequency_);
    }

    uint256[50] private __gap;
}
