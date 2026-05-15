| eip  | title                            | authors                                                      | status | discussions-to                                               | type      | category | created    |
| ---- | -------------------------------- | ------------------------------------------------------------ | ------ | ------------------------------------------------------------ | --------- | -------- | ---------- |
| 1404 | Simple Restricted Token Standard | Ron Gierlach <[@rongierlach](https://github.com/rongierlach)>, James Poole <[@pooleja](https://github.com/pooleja)>, Mason Borda <[@masonicGIT](https://github.com/masonicGIT)>, Lawson Baker <[@lwsnbaker](https://github.com/lwsnbaker)> | Draft  | https://github.com/simple-restricted-token/simple-restricted-token/issues | Standards | ERC      | 2018-07-27 |

# Simple Restricted Token Standard

## Simple Summary

A simple and interoperable standard for issuing tokens with transfer restrictions. The following draws on input from top issuers, law firms, relevant US regulatory bodies, and exchanges.

## Abstract

Current ERC token standards have provided the community with a platform on which to develop a decentralized economy that is focused on building Ethereum applications for the real world. As these applications mature and face consumer adoption, they begin to interface with corporate governance requirements as well as regulations. They must not only be able to meet corporate and regulatory requirements but must also be able to integrate with technology platforms underpinning their associated businesses. What follows is a simple and extendable standard that seeks to ease the burden of integration for wallets, exchanges, and issuers.

## Motivation

Token issuers need a way to restrict transfers of ERC-20 tokens to be compliant with securities laws and other contractual obligations. Current implementations do not address these requirements.

A few emergent examples:

- Enforcing Token Lock-Up Periods
- Enforcing Passed AML/KYC Checks
- Private Real-Estate Investment Trusts
- Delaware General Corporations Law Shares

Furthermore, standards adoption amongst token issuers has the potential to evolve into a dynamic and interoperable landscape of automated compliance.

The following design gives greater freedom / upgradability to token issuers and simultaneously decreases the burden of integration for developers and exchanges.

Additionally, we see fit to provide a pattern by which human-readable messages may be returned when token transfers are reverted. Transparency as to *why* a token's transfer was reverted is of equal importance to the successful enforcement of the transfer restriction itself.

A widely adopted standard for detecting restrictions and messaging errors within token transfers will highly convenience the exchanges, wallets, and issuers of the future.

## Specification

The ERC-20 token provides the following basic features:

```
contract ERC20 {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
```



The ERC-1404 standard builds on ERC-20's interface, adding two functions:

```
contract ERC1404 is ERC20 {
  function detectTransferRestriction (address from, address to, uint256 value) public view returns (uint8);
  function messageForTransferRestriction (uint8 restrictionCode) public view returns (string);
}
```



The logic of `detectTransferRestriction` and `messageForTransferRestriction` are left up to the issuer.

The only requirement is that `detectTransferRestriction` must be evaluated inside a token's `transfer` and `transferFrom` methods.

If, inside these transfer methods, `detectTransferRestriction` returns a value other than `0`, the transaction should be reverted.

## Rationale

The standard proposes two functions on top of the ERC-20 standard. Let's discuss the rationale for each.

1. `detectTransferRestriction` - This function is where an issuer enforces the restriction logic of their token transfers. Some examples of this might include, checking if the token recipient is whitelisted, checking if a sender's tokens are frozen in a lock-up period, etc. Because implementation is up to the issuer, this function serves solely to standardize *where* execution of such logic should be initiated. Additionally, 3rd parties may publicly call this function to check the expected outcome of a transfer. Because this function returns a `uint8` code rather than a boolean or just reverting, it allows the function caller to know the reason why a transfer might fail and report this to relevant counterparties.
2. `messageForTransferRestriction` - This function is effectively an accessor for the "message", a human-readable explanation as to *why* a transaction is restricted. By standardizing message look-ups, we empower user interface builders to effectively report errors to users.

## Backwards Compatibility

By design ERC-1404 is fully backwards compatible with ERC-20.
Some examples of how it may be integrated with common types of restricted tokens may be found [here](https://github.com/simple-restricted-token/simple-restricted-token-standard#readme).

