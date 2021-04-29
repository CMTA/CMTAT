# Split module

This document defines Split Module for the CMTA Token specification.

## Rationale

In traditional finance, securities are usually non-divisible.
Only an integer amount of securities could be held or transferred.

When the price of an individual security unit becomes too high, a split operation could be performed.
During this operation, each security unit is replaced by N units, thus the total number of units in circulation is increased N times.
The price of a new unit usually becomes N times less, thus the value doesn't change.

When the unit price becomes too low, a reverse split operation could be performed.
During a reverse split, every N security units are replaced with a single unit.
Such operation could lead to fractional security amounts being help by certain holders.

CMTA Token specification has to support both, splits and reverse splits of the tokens.

## Use Cases

This section describes the use cases for Split Module.

### Split:Unit

For a particular CMTA Token, anybody may know the current unit size.

### Split:Split

An authorized user may set the unit size for a particular CMTA Token.

## API for Ethereum

This section describes the Ethereum API of Split Module.

### Functions

#### `unit()`

##### Signature:

    function unit ()
    public view returns (uint)

##### Description:

Return the current unit.
A transfer may be allowed only when it either transfers an integer number of units to the destination address, or leaves an integer number of units at the origin address.

#### `split(uint)`

##### Signature:

    function split (uint unit)
    public

##### Description:

Set the new `unit` size for the token.
Only authorized users are allowed to call this function.
Zero unit size is no allowed.

### Events

#### `Split(uint)`

##### Signature:

    event Split (uint unit)

##### Description:

Emitted when the token `unit` size was changed.
