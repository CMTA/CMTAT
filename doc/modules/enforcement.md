# Enforcement Module

This document defines Enforcement Module for the CMTA Token specification.


## API for Ethereum

This section describes the Ethereum API of the Enforcement Module.

### Functions

#### `freeze(address)`

##### Signature:

```solidity
    function freeze (address account)
    public return (bool)
```

#### Description:

Prevents `account` to perform any transfer.
Only authorized users are allowed to call this function.
Returns `true` if the address is not yet frozen, `false` otherwise.

#### `unfreeze(address)`

##### Signature:

```solidity
    function unfreeze (address account)
    public return (bool)
```

#### Description:

Re-authorizes `account` to perform transfers if it was frozen.
Only authorized users are allowed to call this function.
Returns `true` if the address was frozen, `false` otherwise.

#### `frozen(address)`

##### Signature:

```solidity
    function frozen (address account)
    public view returns (bool)
```

##### Description:

Tell, whether the given `account` is frozen.

### Events


#### `Freeze(address,address)`

##### Signature:

```solidity
    event Freeze (address indexed enforcer, address indexed owner)
```

##### Description:

Emitted when address `owner` is frozen by `enforcer`.

#### `Unfreeze(address,address)`

##### Signature:

```solidity
    event Unfreeze (address indexed enforcer, address indexed owner)
```

##### Description:

Emitted when address `owner` is unfrozen by `enforcer`.
