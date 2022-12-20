# Debt Module

This document defines Debt Module for the CMTA Token specification.


### API for Ethereum

This section describes the Ethereum API of Debt Module.

### Functions

#### `setDebt`

##### Signature:

```solidity
setDebt(uint256 interestRate_, uint256 parValue_, string memory guarantor_, string memory bondHolder_, string memory maturityDate_, string memory interestScheduleFormat_, string memory interestPaymentDate_, string memory dayCountConvention_, string memory businessDayConvention_, string memory publicHolidayCalendar_)
```

##### Description:

Set the optional Debt  with the different parameters.
Only authorized users are allowed to call this function.



#### `setInterestRate (uint256 interestRate_)`

##### Signature:

```solidity
function setInterestRate (uint256 interestRate_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional interest rate to the given `interestRate_`.
Only authorized users are allowed to call this function.

#### `setParValue (uint256 parValue_)`

##### Signature:

```solidity
function setParValue (uint256 parValue_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional interest rate to the given `parValue_`.
Only authorized users are allowed to call this function.



#### `setGuarantor (string memory guarantor_)`

##### Signature:

```solidity
function setGuarantor (string memory guarantor_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional Guarantor to the given `guarantor_`.
Only authorized users are allowed to call this function.



#### `setGuarantor (string memory guarantor_)`

##### Signature:

```solidity
function setGuarantor (string memory guarantor_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional Guarantor to the given `guarantor_`.
Only authorized users are allowed to call this function.



#### `setBondHolder (string memory bondHolder_)`

##### Signature:

```solidity
function setBondHolder (string memory bondHolder_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional bondHolder to the given `bondHolder_`.
Only authorized users are allowed to call this function.



#### `setMaturityDate (string memory maturityDate_)`

##### Signature:

```solidity
function setMaturityDate (string memory maturityDate_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional maturityDate to the given `maturityDate_`.
Only authorized users are allowed to call this function.



#### `setInterestScheduleFormat (string memory interestScheduleFormat_)`

##### Signature:

```solidity
function setInterestScheduleFormat (string memory interestScheduleFormat_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional interestScheduleFormat to the given `interestScheduleFormat_`.
Only authorized users are allowed to call this function.



#### `setInterestPaymentDate (string memory interestPaymentDate_)`

##### Signature:

```solidity
function setInterestPaymentDate (string memory interestPaymentDate_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional interestPaymentDate to the given `interestPaymentDate_`.
Only authorized users are allowed to call this function.



#### `setDayCountConvention (string memory dayCountConvention_)`

##### Signature:

```solidity
function setDayCountConvention (string memory dayCountConvention_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional dayCountConvention to the given `interestPaymentDate_`.
Only authorized users are allowed to call this function.

#### `setBusinessDayConvention (string memory businessDayConvention_)`

##### Signature:

```solidity
function setBusinessDayConvention (string memory businessDayConvention_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional businessDayConvention to the given `businessDayConvention_`.
Only authorized users are allowed to call this function.

#### ` setPublicHolidaysCalendar(string memory publicHolidayCalendar_)`

##### Signature:

```solidity
function setPublicHolidaysCalendar(string memory publicHolidayCalendar_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional publicHolidayCalendar to the given `publicHolidayCalendar_`.
Only authorized users are allowed to call this function.

