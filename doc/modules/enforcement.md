# Enforcement Module

This document defines Enforcement Module for the CMTA Token specification.


## API for Ethereum

This section describes the Ethereum API of Forced Transfer Module.

### Functions

#### `enforceTransfer(address,address,uint,string)`

##### Signature:

```solidity
    function enforceTransfer (address owner, address destination, uint amount, string memory reason)
    public
```

#### Description:

Forcefully transfer `amount` of tokens from the `owner` to the `destination` address.
Only authorized users are allowed to call this function.

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


### Events

#### `Enforcement(address,address,uint,reason)`

##### Signature:

```solidity
    event Enforcement (address indexed enforcer, address indexed owner, uint amount, string reason)
```

##### Description:

Emitted when the specified `enforcer` enforced a transfer of the specified `amount` of tokens from the specified `owner` for the specified `reason`.

#### `Freeze(address,address)`

##### Signature:

```solidity
    event Freeze (address indexed enforcer, address indexed owner)
```

##### Description:

#### `Unfreeze(address,address)`

##### Signature:

```solidity
    event Unfreeze (address indexed enforcer, address indexed owner)
```

##### Description:


