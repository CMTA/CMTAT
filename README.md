# CMTA Token 

The CMTA Token (CMTAT) is a framework enabling the tokenization of
equity and debt securities in compliance with the Swiss law.

The CMTAT is an open standard from the the [Capital Markets and
technology association](http://www.cmta.ch/) (CMTA), and the product of
collaborative work by leading organizations in the Swiss finance and
technology ecosystem.

The present repository provides CMTA's reference implementation of CMTAT
for Ethereum, as an ERC-20 compatible token.

The preferred way to receive comments is through the GitHub issue
tracker.  Private comments and questions can be sent to the CMTA secretariat 
at <a href="mailto:admin@cmta.ch">admin@cmta.ch</a>.


## Functionalities 

CMTAT is a *framework* that enables the tokenization of equity and debt
instruments.
CMTAT notably supports the following core features:

* Basic mint, burn, and transfer operations
* Forced transfer by the issuer 
* Pause of the contract and freeze of specific accounts

Furthermore, the present implementation uses standard mechanisms in order to simplify:

* Distribution of dividends and interest, via snapshots
* Upgradeability, via deployemnt of the token with a proxy
* "Gasless" transactions

Please see CMTAT's [technical documentation](doc/CMTAT.pdf) for a more
detailed description of CMTAT's functionalities. **TODO**

Please see the [modules documentation](doc/modules) for the
specification of modules of this reference implementation.


## Practical considerations

To use the CMTAT, we recommend that you use the latest version from the
[Releases](https://github.com/CMTA/CMTAT/releases) page.


### Token templates

**TODO**

This reference implementation allows the creation of two types of tokens:

* *CMTAT-E*, to tokenize equity instruments.

* *CMTAT-D*, to tokenize debt instruments.

These pre-defined tokens are provided for convenience.
One may modify them, by adding, removing, or modifying features, however the core features listed above must remain in place for compliance with the Swiss law.
If you believe changes are needed, we recommend that you contact CMTA to ensure that said changes would not jeopardize the token's security and legal standing.


### Running local tests

**TODO**

### Deployment via a proxy

**TODO, with OZ proxing**

### Support for gasless transactions

**TODO, with OpenGSN support**


## Security audits

**TODO ABDK + report**


## Contributors

The CMTAT is developed by a working group of CMTA's Technical Committee
that includes members from Atpar, Bitcoin Suisse, Blockchain Innovation
Group, Hypothekarbank Lenz & Staehelin, Metaco, SEBA, Swissquote,
Sygnum, Taurus, Tezos Foundation.

The design and security of the CMTAT was supported by
[ABDK](https://abdk.consulting/), a leading team in smart contract
security.

## Intellectual property

The code is copyright (c) Capital Market and Technology Association,
2018-2021, and is released under [Mozilla Public License
2.0](./LICENSE.md).

