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

Set the optional `parValue` to the given `parValue_`.
Only authorized users are allowed to call this function.

#### `setGuarantor (string memory guarantor_)`

##### Signature:

```solidity
function setGuarantor (string memory guarantor_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional attribute `Guarantor` to the given `guarantor_`.
Only authorized users are allowed to call this function.

#### `setBondHolder (string memory bondHolder_)`

##### Signature:

```solidity
function setBondHolder (string memory bondHolder_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional attribute `bondHolder` to the given `bondHolder_`.
Only authorized users are allowed to call this function.

#### `setMaturityDate (string memory maturityDate_)`

##### Signature:

```solidity
function setMaturityDate (string memory maturityDate_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional attribute `maturityDate` to the given `maturityDate_`.
Only authorized users are allowed to call this function.

#### `setInterestScheduleFormat (string memory interestScheduleFormat_)`

##### Signature:

```solidity
function setInterestScheduleFormat (string memory interestScheduleFormat_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional attribute `interestScheduleFormat` to the given `interestScheduleFormat_`.
Only authorized users are allowed to call this function.

#### `setInterestPaymentDate (string memory interestPaymentDate_)`

##### Signature:

```solidity
function setInterestPaymentDate (string memory interestPaymentDate_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional attribute `interestPaymentDate` to the given `interestPaymentDate_`.
Only authorized users are allowed to call this function.

#### `setDayCountConvention (string memory dayCountConvention_)`

##### Signature:

```solidity
function setDayCountConvention (string memory dayCountConvention_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional attribute `dayCountConvention` to the given `interestPaymentDate_`.
Only authorized users are allowed to call this function.

#### `setBusinessDayConvention (string memory businessDayConvention_)`

##### Signature:

```solidity
function setBusinessDayConvention (string memory businessDayConvention_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional attribute `businessDayConvention` to the given `businessDayConvention_`.
Only authorized users are allowed to call this function.

#### ` setPublicHolidaysCalendar(string memory publicHolidayCalendar_)`

##### Signature:

```solidity
function setPublicHolidaysCalendar(string memory publicHolidayCalendar_) public onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional attribute `publicHolidayCalendar` to the given `publicHolidayCalendar_`.
Only authorized users are allowed to call this function.

### Events

#### `InterestRateSet(uint256)`

##### Signature:

```solidity
   event InterestRateSet(uint256 indexed newInterestRate)`
```

##### Description:

Emitted when the attribute `Interest Rate` is set.

#### `ParValueSet(uint256)`

##### Signature:

```solidity
    event ParValueSet(uint256 indexed newParValue)
```

##### Description:

Emitted when the attribute `ParValue` is set.

#### `GuarantorSet(string, string)`

##### Signature:

```solidity
  event GuarantorSet(string indexed newGuarantorIndexed, string newGuarantor)
```

##### Description:

Emitted when the attribute `Guarantor` is set.

#### `BondHolderSet(string, string)`

##### Signature:

```solidity
  event BondHolderSet(string indexed newBondHolderIndexed, string newBondHolder)
```

##### Description:

Emitted when the attribute `BondHolder` is set.

#### `MaturityDateSet(string, string)`

##### Signature:

```solidity
event MaturityDateSet(string indexed newMaturityDateIndexed, string newMaturityDate);
```

##### Description:

Emitted when the attribute `maturityDate` is set.

#### `InterestScheduleFormatSet(string, string)`

##### Signature:

```solidity
event MaturityDateSet(string indexed newMaturityDateIndexed, string newMaturityDate);
```

##### Description:

Emitted when the attribute `maturityDate` is set.

#### `InterestPaymentDateSet(string, string)`

##### Signature:

```solidity
event MaturityDateSet(string indexed newMaturityDateIndexed, string newMaturityDate);
```

##### Description:

Emitted when the attribute `InterestScheduleFormatSet` is set.

#### `DayCountConventionSet(string, string)`

##### Signature:

```solidity
event DayCountConventionSet(string indexed newDayCountConventionIndexed, string newDayCountConvention)
```

##### Description:

Emitted when the attribute `DayCountConventionSet` is set.

#### `BusinessDayConventionSet(string, string)`

##### Signature:

```solidity
event BusinessDayConventionSet(string indexed newBusinessDayConventionIndexed, string newBusinessDayConvention)
```

##### Description:

Emitted when the attribute `BusinessDayConventionSet` is set.

#### `PublicHolidaysCalendarSet(string, string)`

##### Signature:

```solidity
event PublicHolidaysCalendarSet(string indexed newPublicHolidaysCalendarIndexed, string newPublicHolidaysCalendar)
```

##### Description:

Emitted when the attribute `PublicHolidaysCalendarSet` is set.
