# Pause Module

This document defines the Pause Module for the CMTA Token specification.


## API for Ethereum

This section describes the Ethereum API of the Pause Module.

### Functions

#### `pause()`

##### Signature:

```solidity
    function pause (string memory reason)
    public
```

##### Description:

Pause all the token transfers for the given `reason`.
This function doesn't affect forced transfers, issuance, redemption, and approves.
Only authorized users are allowed to call this function.

#### `unpause()`

##### Signature:

Unpause token transfers.
Only authorized users are allowed to call this function.

### Events

#### `Pause(string)`

##### Signature:

```solidity
    event Pause (string reason)
```

##### Description:

Emitted when token transfers were frozen for the specified `reason`.

#### `Unpause()`

##### Signature:

```solidity
    events Unpause ()
```

##### Description:

Emitted when token transfers were unfrozen.
