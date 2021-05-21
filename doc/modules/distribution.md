# Distribution Module

This document defines the Distribution Module for the CMTA Token specification.

## Rationale

Dividends (for equity tokens) and interest (for debt tokens) entail the
distribution of assets to token holders, on the basis of a snapshot,
according to a business logic defining the distribution (for example,
proportionally to the tokens owned, and/or according to an interest
rate). Not all token holders may be eligible for distribution (for
example, if they have not properly identified themselves). The
Distribution Module allows the issuer to make the distribution of other
assets to token holders.

## Use Cases

## Distribution:CreateParameters

Define settlement token (i.e., the asset to be distributed), identify a (past or future) block time/height for distribution snapshot, and amount to be distributed.

## Distribution:SetElibility

Flag given users' tokens as being eligible or non-eligible to receive distributions (default: eligible).

   
## Distribution:MakeDeposit

Send deposit amount for claiming settlement tokens to token holders flagged as eligible.


## Distribution:ClaimDeposit

Token holder claims their share of a deposit, identified by the depositId, according to the token balance at the snapshot created at the defined time/height.


## API for Ethereum



