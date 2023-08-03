# FAQ

This FAQ is intended to developers familiar with smart contracts
development.

## Toolkit support

> Why do you continue using Truffle instead of migrating to HardHat or Foundry?

Regarding [Hardhat](https://hardhat.org/):

- Our tests are not working with Hardhat so to migrate to hardhat, we will have to update our tests which will require a lot of works.
- Moreover, we do not see a use case where hardhat will be better than Truffle.
- Hardhat has a lot of plugins, but for example, for the coverage, we can run the coverage without be fully compatible with Hardhat.

Regarding [Foundry](https://book.getfoundry.sh/):

-  The plugin "upgrades plugin" by OpenZeppelin is not available with Foundry and it is a very good tool to check the proxy implementation and perform automatic tests. See [https://docs.openzeppelin.com/upgrades-plugins/1.x/](https://docs.openzeppelin.com/upgrades-plugins/1.x/)
-  The tests for the gasless module (MetaTx) would be difficult to write
   in Solidity, as Foundry requires, see [https://github.com/CMTA/CMTAT/blob/master/test/common/MetaTxModuleCommon.js](https://github.com/CMTA/CMTAT/blob/master/test/common/MetaTxModuleCommon.js)
- The OpenZeppelin libraries that we use have their tests mainly written in JavaScript, which provides a good basis for our tests
- Performance wise, we observed that Foundry is superior to Truffle, notably to test the Snapshot module
- We have a repository [CMTA/CMTAT-Foundry](https://github.com/CMTA/CMTAT-foundry) that provides experimental support for Foundry, but it does not provide complete support and testing for the latest CMTAT version.


>  Do you plan to fully support Foundry in the near future? 

For the foreseeable future, we plan to keep Truffle as the main
development and testing suite.

We have not planned to export all the tests from the Truffle suite to
their Solidity version equivalent suitable to Foundry, though some tests
are already available.

The CMTAT-Foundry repository uses CMTAT as a submodule, whose version is
documented in its
[README](https://github.com/CMTA/CMTAT-Foundry/blob/main/README.md#cmtat---using-the-foundry-suite).


>  Can Hardhat be used to run tests?

No, please use Truffle to run the tests.


## Modules

> What is the reason the Snapshot module wasn't audited in version v2.3.0?

This module was left out of scope because it is not used yet (and not
included in a default deployment) and will be
subject to changes soon. 

> What is the status of [ERC1404](https://erc1404) compatibility?

We have not planned to be fully compatible with ERC1404 (which, in fact,
is only an EIP at the time of writing). 
CMTAT includes the two functions defind by ERC1404, namely
`detectTransferRestriction` and `messageForTransferRestriction`.
Thus CMTAT can provide the same functionality as ERC1404.

However, from a pure technical perspective, CMTAT is not fully compliant
with the ERC1404 specification, due the way it inherits the ERC20
interface. 

> What is the purpose of the flag parameter in the Base module?

It is just a variable to include some additional information under the form of bit fields.
It is not used inside the code because it is destined to provide more
information on the tokens to the "outside", for example for the token
owners.


> Is the Validation module optional? 

Generally, for a CMTAT token, the Validation functionality is optional
from the legal perspective (please contact admin@cmta.ch for detailed
information).

However, in order to use the functions from the Pause and Enforcement
modules, our CMTAT implementation requires the Validation module
Therefore, the Validation module is effectively required *in this
implementation*. 

If you remove the Validation module and want to use the Pause or the
Enforcement module, you have to call the functions of modules inside the
main contracts. It was initially the case but we have changed this
behaviour when addressing an issue reported by a security audit.
Here is an old version:
[https://github.com/CMTA/CMTAT/blob/ed23bfc69cfacc932945da751485c6472705c975/contracts/CMTAT.sol#L205](https://github.com/CMTA/CMTAT/blob/ed23bfc69cfacc932945da751485c6472705c975/contracts/CMTAT.sol#L205),
and the relevant Pull [Request](https://github.com/CMTA/CMTAT/pull/153).


## Documentation

> What is the code coverage of the test suite?

A [code coverage report](https://github.com/CMTA/CMTAT/blob/master/doc/general/test/coverage/index.html)
is available.

Normally, you can run the test suite and generate a code coverage report with `npx hardhat coverage`.

Please clone the repository and open the file inside your browser.

You will find a summary of all automatic tests in
[test.pdf](https://github.com/CMTA/CMTAT/blob/master/doc/general/test/test.pdf).
