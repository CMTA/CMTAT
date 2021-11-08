# Mint Module

This document defines Mint Module for the CMTA Token specification.

## Rationale

Traditional securities could be issued in different ways.  Bonds are
usually issued all at once.  Normal shares could be issued several
times, when the issuer wants to raise more capital.  ETF shares are
continuously issued on demand.  The Mint Module covers scenarios for
CMTA Token specification when the issuer needs to
create new tokens in response to securities issuances

## API for Ethereum

This section describes the Ethereum API of Issue Module.

### Function

#### `mint(address,uint)`

##### Signature:

```solidity
    function issue (address to, uint amount)
    public
```

##### Description:

Create the given `amount` of tokens and allocate them to the given `beneficiary`.
Only authorized users are allowed to call this function.

### Events

#### `Mint(address,uint)`

##### Signature:


```solidity
    event Mint (address indexed beneficiary, uint amount)
```

##### Description

Emitted when the specified `amount` of new tokens was created and
allocated to the specified `beneficiary`.
 
