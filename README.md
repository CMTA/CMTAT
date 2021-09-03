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


## Functionality

The CMTAT supports the following core features:

* Basic mint, burn, and transfer operations
* Forced transfer by the issuer 
* Pause of the contract and freeze of specific accounts

Furthermore, the present implementation uses standard mechanisms in order to simplify:

* Distribution of dividends and interest, via snapshots
* Upgradeability, via deployemnt of the token with a proxy
* "gasless" transactions

Please see CMTAT's [technical documentation](doc/CMTAT.pdf) for a more
detailed description of CMTAT's functionalities. 
Please see the [modules documentation](doc/modules) for the
specification of modules of this reference implementation.

This reference implementation allows the issuance and management of
tokens representing company equity.
A future version will implement support for debt instruments.

One may modify the token code, by adding, removing, or modifying
features, however the core features listed in the [technical
documentation](doc/CMTAT.pdf) must remain in place for compliance with
the Swiss law.

To use the CMTAT, we recommend that you use the latest version from the
[Releases](https://github.com/CMTA/CMTAT/releases) page.


### Running local tests

**TODO**

### Deployment via a proxy

The CMTAT supports deployment via a proxy, as it takes the requirements for use with a proxy in consideration.
Furthermore, by using a proxy, you can also upgrade the contract using a proxy upgrade pattern.

Please see the OpenZeppelin [upgradeable contracts documentation](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable) for more information about the proxy requirements applied to the contract.

Please see the OpenZeppelin [Upgrades plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/) for more information about upgrades plugins in general.

Note that the deployment via a proxy is not mandatory, but recommended by CMTA.

### Support for gasless transactions

The CMTAT supports client-side gasless transactions using the [Gas Station Network](https://docs.opengsn.org/#the-problem) pattern, the main open standard for transfering fee payment to another account than the transaction issuer. The contract uses the OpenZeppelin contract `ERC2771ContextUpgradeable`, which allows to get the original client with `_msgSender()` instead of the fee payer given by `msg.sender` while allowing upgrades on the main contract (see *Deployment via a proxy* above).

Please see the OpenGSN [documentation](https://docs.opengsn.org/contracts/#receiving-a-relayed-call) for more details on what is done to support GSN in the contract.


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

