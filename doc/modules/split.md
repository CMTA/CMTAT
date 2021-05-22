# Split module

This document defines Split Module for the CMTA Token specification.

## API for Ethereum

This section describes the Ethereum API of Split Module.

### Functions

#### `unit()`

##### Signature:

```solidity
    function unit ()
    public view returns (uint)
```

##### Description:

Return the current unit.
A transfer may be allowed only when it either transfers an integer number of units to the destination address, or leaves an integer number of units at the origin address.

#### `split(uint)`

##### Signature:

```solidity
    function split (uint unit)
    public
```

##### Description:

Set the new `unit` size for the token.
Only authorized users are allowed to call this function.
Zero unit size is no allowed.

### Events

#### `Split(uint)`

##### Signature:

```solidity
    event Split (uint unit)
```

##### Description:

Emitted when the token `unit` size was changed.
