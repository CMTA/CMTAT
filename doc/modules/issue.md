# Issue Module

This document defines Issue Module for the SMTA Token specification.

## Rationale

Traditional securities could be issued in different ways.  Bonds are usually issues all at once.  Normal shares could be issued several times, when the issuer wants to raise more capital.  ETF shares are continuously issued on demand.  Issues module covers issuance scenarios for CMTA Token specification.

## API for Ethereum

This section describes the Ethereum API of Issue Module.

### Function

#### `issue(address,uint)`

##### Signature:

    function issue (address beneficiary, uint amount)
    public

##### Description:

Issue the given `amount` of tokens to the given `beneficiary`.
Only authorized users are allowed to call this function.

### Events

#### `Issue(address,uint)`

##### Signature:

    event Issue (address indexed beneficiary, uint amount)

##### Description

Emitted when the specified `amount` of new tokens was issued to the specified `beneficiary`.
 