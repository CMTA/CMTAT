# FAQ

This FAQ is intended to developers familiar with smart contracts
development.

## Toolkit support

> Which is the main development tool you use ?

Since the sunset of Truffle by Consensys, we use Hardhat

Regarding [Foundry](https://book.getfoundry.sh/):

- All our tests are written in Javascript and migrating them to Foundry will require a lot of work
- The tests for the gasless module (MetaTx) would be difficult to write in Solidity, as Foundry requires, see [https://github.com/CMTA/CMTAT/blob/master/test/common/MetaTxModuleCommon.js](https://github.com/CMTA/CMTAT/blob/master/test/common/MetaTxModuleCommon.js)
  
-  The OpenZeppelin libraries that we use have their tests mainly written in JavaScript, which provides a good basis for our tests


>  Do you plan to fully support Foundry in the near future? 

For the foreseeable future, we plan to keep Hardhat  as the main development and testing suite.


>  Can Truffle be used to run tests?

No. Since the version v.2.31 and the use of `custom errors`, the tests no longer work with Truffle.

You can only run the tests with `Hardhat`.


## Modules

> What is the reason the Snapshot module wasn't audited in version v2.3.0?

This module was left out of scope because it is not used yet (and not included in a default deployment) and will be subject to changes soon. 

In CMTAT v3.0.0, this module has been removed and replaced by the module `SnapshotEngine`.

> What is the status of [ERC-1404](https://github.com/ethereum/EIPs/issues/1404) compatibility?

CMTAT (and the RuleEngine) implement **both** versions of ERC-1404:

- the **original** ERC-1404 — `detectTransferRestriction` and `messageForTransferRestriction` (`IERC1404`) — which was only ever published as a [GitHub issue](https://github.com/ethereum/EIPs/issues/1404) and never became a merged EIP;
- its **current rework**, the draft proposal ["Simple Restricted Token" (ethereum/ERCs PR #1701)](https://github.com/ethereum/ERCs/pull/1701), which adds the spender-aware `detectTransferRestrictionFrom` (`IERC1404Extend`).

Note that ERC-1404 is still a draft in both forms — not an official, merged ERC.


> Is the Validation module optional? 

Generally, for a CMTAT token, the Validation functionality is optional
From the legal perspective (please contact CMTA association for detailed information, see REDME - Introduction).

However, in order to use the functions from the Pause and Enforcement modules, our CMTAT implementation requires the Validation module.

If you remove the Validation module and want to use the Pause or the Enforcement module, you have to call the functions of modules inside the main base contracts. It was initially the case but we have changed this behavior when addressing an issue reported by a security audit.
Here is an old version:
[https://github.com/CMTA/CMTAT/blob/ed23bfc69cfacc932945da751485c6472705c975/contracts/CMTAT.sol#L205](https://github.com/CMTA/CMTAT/blob/ed23bfc69cfacc932945da751485c6472705c975/contracts/CMTAT.sol#L205), and the relevant Pull [Request](https://github.com/CMTA/CMTAT/pull/153).


## Documentation

> What is the code coverage of the test suite?

A [code coverage report](../test/coverage/index.html) is available.

Normally, you can run the test suite and generate a code coverage report with `npx hardhat coverage`.

Please clone the repository and open the file inside your browser.
