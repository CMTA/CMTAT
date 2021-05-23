# Redeem Module

This document defines Redeem Module for the CMTA Token specification.

## Rationale

In some cases traditional securities could be redeemed by their holder for some benefits.  For example a convertible bond could be redeemed for shares, or a number of ETF shares could be redeemed for the base assets.
Redeem module convers redemption scenarios for the CMTA Token specification.

### API for Ethereum

This section describes the Ethereum API of Redeem Module.

### Functions

#### `redeemFrom(address,uint)`

##### Signature:

    function redeemFrom (address owner, uint amount)
    public

##### Description:

Redeem the given `amount` of tokens from the given `owner`.
The owner should `approve` the redemption in advance in the same way as `transferFrom` calls are approved.
Only authorized users are allowed to call this function.

### Events

#### `Redemption(address,uint)`

##### Signature:

    event Redemption (address indexed owner, uint amount)`

##### Description:

Emitted when the specified `amount` of tokens was redeemed from the specified `owner`.
