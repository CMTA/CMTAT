# Burn Module

This document defines Burn Module for the CMTA Token specification.


### API for Ethereum

This section describes the Ethereum API of Burn Module.

### Functions

#### `forceBurn(address,uint)`

##### Signature:

```solidity
function forceBurn(address account, uint256 amount)
        public
        onlyRole(BURNER_ROLE)
```

##### Description:

Redeem the given `amount` of tokens from the given `account`.
Only authorized users are allowed to call this function.

### Events

#### `Burn(address,uint)`

##### Signature:

```solidity
    event Burn (address indexed account, uint amount)`
```

##### Description:

Emitted when the specified `amount` of tokens was burnt from the specified `account`.
