//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../interfaces/IDebt.sol";
import "../../security/AuthorizationModule.sol";

abstract contract DebtModule is IDebt,  Initializable, ContextUpgradeable, AuthorizationModule {
    

    Debt public debt;

    /* Events */
    event InterestRateSet(uint256 indexed newInterestRate);
    event ParValueSet(uint256 indexed newParValue);
    event GuarantorSet(string indexed newGuarantorIndexed, string newGuarantor);
    event BondHolderSet(string indexed newBondHolderIndexed, string newBondHolder);
    event MaturityDateSet(string indexed newMaturityDateIndexed, string newMaturityDate);
    event InterestScheduleFormatSet(string indexed newInterestScheduleFormatIndexed, string newInterestScheduleFormat);
    event InterestPaymentDateSet(string indexed newInterestPaymentDateIndexed, string newInterestPaymentDate);
    event DayCountConventionSet(string indexed newDayCountConventionIndexed, string newDayCountConvention);
    event BusinessDayConventionSet(string indexed newBusinessDayConventionIndexed, string newBusinessDayConvention);
    event PublicHolidaysCalendarSet(string indexed newPublicHolidaysCalendarIndexed, string newPublicHolidaysCalendar);
    
    
    function __DebtModule_init() internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();

         // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
    }

    function __DebtModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    function setDebt(uint256 interestRate_, uint256 parValue_, string memory guarantor_, string memory bondHolder_, 
    string memory maturityDate_, string memory interestScheduleFormat_, string memory interestPaymentDate_, 
    string memory dayCountConvention_, 
    string memory businessDayConvention_, string memory publicHolidayCalendar_) public onlyRole(DEBT_ROLE) {
        // setGuarantor
        debt = 
        (Debt(interestRate_, parValue_, guarantor_, bondHolder_, maturityDate_, interestScheduleFormat_, interestPaymentDate_, 
        dayCountConvention_, businessDayConvention_, publicHolidayCalendar_));
        emit InterestRateSet(interestRate_);
        emit ParValueSet(parValue_);
        emit GuarantorSet(guarantor_, guarantor_);
        emit BondHolderSet(bondHolder_, bondHolder_);
        emit MaturityDateSet(maturityDate_, maturityDate_);
        emit InterestScheduleFormatSet(interestScheduleFormat_, interestScheduleFormat_);
        emit InterestPaymentDateSet(interestPaymentDate_, interestPaymentDate_);
        emit DayCountConventionSet(dayCountConvention_, dayCountConvention_);
        emit BusinessDayConventionSet(businessDayConvention_, businessDayConvention_);
        emit PublicHolidaysCalendarSet(publicHolidayCalendar_, publicHolidayCalendar_);
    }

    function setInterestRate (uint256 interestRate_) public onlyRole(DEBT_ROLE) {
        debt.interestRate = interestRate_;
        emit InterestRateSet(interestRate_);
    }

    function setParValue (uint256 parValue_) public onlyRole(DEBT_ROLE) {
        debt.parValue = parValue_;
        emit ParValueSet(parValue_);
    }

    function setGuarantor (string memory guarantor_) public onlyRole(DEBT_ROLE) {
        debt.guarantor = guarantor_;
        emit GuarantorSet(guarantor_, guarantor_);
    }

    function setBondHolder (string memory bondHolder_) public onlyRole(DEBT_ROLE) {
        debt.bondHolder = bondHolder_;
        emit BondHolderSet(bondHolder_, bondHolder_);
    }

    function setMaturityDate (string memory maturityDate_) public onlyRole(DEBT_ROLE) {
        debt.maturityDate = maturityDate_;
        emit MaturityDateSet(maturityDate_, maturityDate_);
    }

    function setInterestScheduleFormat (string memory interestScheduleFormat_) public onlyRole(DEBT_ROLE) {
        debt.interestScheduleFormat = interestScheduleFormat_;
        emit InterestScheduleFormatSet(interestScheduleFormat_, interestScheduleFormat_);
    }

    function setInterestPaymentDate (string memory interestPaymentDate_) public onlyRole(DEBT_ROLE) {
        debt.interestPaymentDate = interestPaymentDate_;
        emit InterestPaymentDateSet(interestPaymentDate_, interestPaymentDate_);
    }

    function setDayCountConvention (string memory dayCountConvention_) public onlyRole(DEBT_ROLE) {
        debt.dayCountConvention = dayCountConvention_;
        emit DayCountConventionSet(dayCountConvention_, dayCountConvention_);
    }

    function setBusinessDayConvention (string memory businessDayConvention_) public onlyRole(DEBT_ROLE) {
        debt.businessDayConvention = businessDayConvention_;
        emit BusinessDayConventionSet(businessDayConvention_, businessDayConvention_);
    }

    function setPublicHolidaysCalendar(string memory publicHolidayCalendar_) public onlyRole(DEBT_ROLE) {
        debt.publicHolidayCalendar = publicHolidayCalendar_;
        emit PublicHolidaysCalendarSet(publicHolidayCalendar_, publicHolidayCalendar_);
    }

    uint256[50] private __gap;
}
