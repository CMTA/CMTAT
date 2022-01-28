# CMTA Token 

The CMTA token (CMTAT) is a framework enabling the tokenization of
securities in compliance with Swiss law.

The CMTAT is an open standard from the [Capital Markets and
Technology Association](http://www.cmta.ch/) (CMTA), and the product of
collaborative work by leading organizations in the Swiss finance and
technology ecosystem.

The present repository provides CMTA's reference implementation of CMTAT
for Ethereum, as an ERC-20 compatible token.

The CMTAT is developed by a working group of CMTA's Technical Committee
that includes members from Atpar, Bitcoin Suisse, Blockchain Innovation
Group, Hypothekarbank Lenzburg, Lenz & Staehelin, Metaco, Mt Pelerin,
SEBA, Swissquote, Sygnum, Taurus and Tezos Foundation. The design and
security of the CMTAT was supported by ABDK, a leading team in smart
contract security.

The preferred way to receive comments is through the GitHub issue
tracker.  Private comments and questions can be sent to the CMTA secretariat 
at <a href="mailto:admin@cmta.ch">admin@cmta.ch</a>.

## Functionality

The CMTAT supports the following core features:

* Basic mint, burn, and transfer operations
* Pause of the contract and freeze of specific accounts

Furthermore, the present implementation uses standard mechanisms in
order to support:

* Distribution of dividends and interest, via snapshots
* Upgradeability, via deployment of the token with a proxy
* "Gasless" transactions
* Conditional transfers, via a rule engine

This reference implementation allows the issuance and management of
tokens representing equity securities.
It can however also be used for other forms of financial instruments
such as debt securities.

To use the CMTAT, we recommend that you use the latest audited version,
from the [Releases](https://github.com/CMTA/CMTAT/releases) page.

You may modify the token code by adding, removing, or modifying
features. However, the base, enforcement, and snapshot modules must
remain in place for compliance with Swiss law.

### Proxying support

The CMTAT supports deployment via a proxy contract.  Furthermore, using
a proxy permits to upgrade the contract, using a standard proxy upgrade
pattern.

Please see the OpenZeppelin [upgradeable contracts
documentation](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable)
for more information about the proxy requirements applied to the
contract.

Please see the OpenZeppelin [Upgrades
plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/) for more
information about upgrades plugins in general.

Note that deployment via a proxy is not mandatory, but recommended by CMTA.

### Gasless support

The CMTAT supports client-side gasless transactions using the [Gas
Station Network](https://docs.opengsn.org/#the-problem) (GSN) pattern, the
main open standard for transfering fee payment to another account than
that of the transaction issuer. The contract uses the OpenZeppelin contract
`ERC2771ContextUpgradeable`, which allows a contract to get the original client
with `_msgSender()` instead of the fee payer given by `msg.sender` while
allowing upgrades on the main contract (see *Deployment via a proxy*
above).

Please see the OpenGSN
[documentation](https://docs.opengsn.org/contracts/#receiving-a-relayed-call)
for more details on what is done to support GSN in the contract.

## Kill switch

A "kill switch" is a necessary function to allow the issuer to
carry out certain corporate actions (e.g., share splits, reverse splits,
and mergers), which involve cancelling all existing tokens and replacing
them by new ones, and can also be used if the issuer decides that it no
longer wishes to have its shares issued in the form of ledger
securities. The "kill switch" function affects all tokens issued.

Such a functionality can be performed via that `kill()` function.
A new token contract may then be deployed via the proxy.
Alternatively, if interactions with the "killed contract" are still
necessary, it may be paused (and never unpaused).


## Security 

The contracts have been audited by [ABDK
Consulting](https://www.abdk.consulting/), a globally recognized
firm specialized in smart contracts' security.

Fixes of security issues discovered by the initial audit were reviewed
by ABDK and confirmed to be effective, as certified by the [report
released](doc/audits/ABDK-CMTAT-audit-20210910.pdf) on September 10, 2021],
covering [version
c3afd7b](https://github.com/CMTA/CMTAT/tree/c3afd7b4a2ade160c9b581adb7a44896bfc7aaea)
of the contracts.
Version [1.0](https://github.com/CMTA/CMTAT/releases) includes
additional fixes of minor issues, compared to the version retested.


As with any token contract, access to the owner key must be adequately
restricted.
Likewise, access to the proxy contract must be restricted and
seggregated from the token contract.

## Documentation

Please see the [doc/modules](doc/modules) for documentation of the
modules API.

CMTA will release further documentation describing the CMTAT framework
in a platform-agnostic way, and coveging legal aspects.

## Testing

Tests are written in JavaScript (Node.js package) and run with Truffle through the command `truffle test`. 
The test suite could be correctly built and run with the following versions: 

* Node.js 10.13.0
* npm 6.4.1
* Truffle 5.3.8

Truffle has to be installed globally or used with the `npx` command.
Everything else needed is installed through `npm install` with the right
versions.

Please see the Truffle [JavaScript tests
documentation](https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript)
for more information about the writing and running of Truffle tests.



## Intellectual property

The code is copyright (c) Capital Market and Technology Association,
2018-2021, and is released under [Mozilla Public License
2.0](./LICENSE.md).


