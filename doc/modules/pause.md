# Pause Module

This document defines the Pause Module for the CMTA Token specification.


## API for Ethereum

This section describes the Ethereum API of the Pause Module.

### Functions

#### `pause()`

##### Signature:

```solidity
    function pause ()
    public
```

##### Description:

Pause all the token transfers.
This function doesn't affect issuance, redemption, and approves.
Only authorized users are allowed to call this function.

#### `unpause()`

##### Signature:

Unpause token transfers.
Only authorized users are allowed to call this function.

### Events

#### `Pause()`

##### Signature:

```solidity
    event Pause ()
```

##### Description:

Emitted when token transfers were paused.

#### `Unpause()`

##### Signature:

```solidity
    events Unpause ()
```

##### Description:

Emitted when token transfers were unpaused.
