# Burn Module

This document defines Burn Module for the CMTA Token specification.


### API for Ethereum

This section describes the Ethereum API of Burn Module.

### Functions

#### `burnFrom(address,uint)`

##### Signature:

```solidity
    function burnFrom (address account, uint amount)
    public
```

##### Description:

Redeem the given `amount` of tokens from the given `account`.
The owner should `approve` the redemption in advance in the same way as `transferFrom` calls are approved.
Only authorized users are allowed to call this function.

### Events

#### `Burn(address,uint)`

##### Signature:

```solidity
    event Burn (address indexed account, uint amount)`
```

##### Description:

Emitted when the specified `amount` of tokens was burnt from the specified `account`.
