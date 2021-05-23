# Freeze Module

This document defines Freeze Module for the CMTA Token specification.

## Rationale

In force majeure conditions or during reorganization, it could be necessary to freeze CMTA Token transfer, either temporary or permanently.
Freeze Module covers such use cases.

## API for Ethereum

This section describes the Ethereum API of Freeze Module.

### Functions

#### `freeze()`

##### Signature:

    function freeze (string memory reason)
    public

##### Description:

Freeze all the token transfers for the given `reason`.
This function doesn't affect forced transfers, issuance, redemption, and approves.
Only authorized users are allowed to call this function.

#### `unfreeze()`

##### Signature:

Unfreeze token transfers.
Only authorized users are allowed to call this function.

### Events

#### `Freeze(string)`

##### Signature:

    event Freeze (string reason)

##### Description:

Emitted when token transfers were frozen for the specified `reason`.

#### `Unfreeze()`

##### Signature:

    events Unfreeze ()

##### Description:

Emitted when token transfers were unfrozen.
