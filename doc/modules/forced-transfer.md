# Forced Transfer Module

This document defines Forced Transfer Module for the CMTA Token specification.

## Rationale

In modern finance, where most of securities exist in electric form in centralized depositories, it is possible to forcefully transfer securities in order to enforce a court decision or fulfill regulator requirements.

CMTA Tokens has to support such functionality and allow authorized users to forcefully transfer tokens from other token holders.

## Use Cases

This section describes use cases for Forced Transfer Module.

### ForceTransfer:EnforceTransfer

An authorized user may transfer tokens owned by an arbitrary token owner to an arbitrary destination address.

## API for Ethereum

This section describes the Ethereum API of Forced Transfer Module.

### Functions

#### `enforceTransfer(address,address,uint,string)`

##### Signature:

    function enforceTransfer (address owner, address destination, uint amount, string memory reason)
    public

#### Description:

Forcefully transfer `amount` of tokens from the `owner` to the `destination` address.
Only authorized users are allowed to call this function.

### Events

#### `Enforcement(address,address,uint,reason)`

##### Signature:

    event Enforcement (address indexed enforcer, address indexed owner, uint amount, string reason)

##### Description:

Emitted when the specified `enforcer` enforced a transfer of the specified `amount` of tokens from the specified `owner` for the specified `reason`.
