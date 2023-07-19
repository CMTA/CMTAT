# FAQ

## IDE (Truffle, Hardhat, ...)

> Why do you continue using Truffle instead of migrating to HardHat or Foundry?

**Hardhat VS Truffle**

- Our tests are not working with Hardhat so to migrate to hardhat, we will have to update our tests which will require a lot of works.
- Moreover, we do not see a use case where hardhat will be better than Truffle.
- Hardhat has a lot of plugins, but for example, for the coverage, we can run the coverage without be fully compatible with Hardhat.

**Truffle VS  Foundry**

-  The plugin "upgrades plugin" by OpenZeppelin is not available with Foundry and it is a very good tool to check the proxy implementation and perform automatic tests. See [https://docs.openzeppelin.com/upgrades-plugins/1.x/](https://docs.openzeppelin.com/upgrades-plugins/1.x/)
-  The tests for the gasless module (MetaTx) will be difficult to write in Solidity, see [https://github.com/CMTA/CMTAT/blob/master/test/common/MetaTxModuleCommon.js](https://github.com/CMTA/CMTAT/blob/master/test/common/MetaTxModuleCommon.js)
- OpenZeppelin, the main libraries we use, have their tests mainly written in JavaScript, so it provides good examples for our tests
- But for performance, we have seen indeed that Foundry is better than Truffle, notably to test the Snapshot Module

>  Do you plan to support Foundry in the near Future? I see a CMTAT-Foundry repo. Is it reliable?

No, it is currently not reliable.

We have not planned to export all the tests in their Solidity version, but some tests are available

The repo CMTAT-Foundry will have the latest CMTAT version

Please, note that we provide only a minimal support for the foundry repository as well as Hardhat.

We use Truffle to maintain the project.

>  Hardhat tests: are they really working in v2.3.0?

No, please use Truffle to run the tests

## Modules

>  Why the Snapshot module is not audited in the version v2.3.0?

It was out of scope because it’s not really used yet and will likely be subject to changes soon.

At deployment, this module is not included by default

> What is the status for ERC1404 compatibility?

We have not planned to be fully compatible since this ERC is not an ERC, it is only an EIP. 

To be fully compatible, we have to inherit of ERC20 inside the interface and it will break our architecture.

See [https://erc1404.org/](https://erc1404.org/)

> What is exactly the purpose of the flag parameter in BaseModule?
> I see that it’s a variable (uint256) to include some information, but I don’t see any use case in the code.

It is just a variable to include some additional information under the form of bit flags.
It is not used inside the code because it is destined to provide more information on the tokens to the "outside", for example for the token owners.



>  Question regarding the ValidationModule optional module. 
>
> Why is it optional? The module is required by Pauser and Enforcer mandatory modules

- ValidationModule is optional from the legal perspective, but you can ask admin@cmta.ch to have a better/clearer information on that.
- It is the opposite: PauseModule and EnforcementModule are required to use the ValidationModule (but indeed, you actually need the ValidationModule for the functions to be called)
- If you remove the ValidationModule and want to use the Pause and Enforcement module, you have to call the functions of modules inside the main contracts. It was initially the case but we have changed this behaviour by fixing the CVF-1
Here an old version: [https://github.com/CMTA/CMTAT/blob/ed23bfc69cfacc932945da751485c6472705c975/contracts/CMTAT.sol#L205](https://github.com/CMTA/CMTAT/blob/ed23bfc69cfacc932945da751485c6472705c975/contracts/CMTAT.sol#L205)
The PR: [https://github.com/CMTA/CMTAT/pull/153](https://github.com/CMTA/CMTAT/pull/153)
We could probably move the ValidationModule inside the mandatory modules and think about a better architecture (but probably not for the next release)

## Documentation

> What is the code coverage?

A code coverage is available here: [https://github.com/CMTA/CMTAT/blob/master/doc/general/test/coverage/index.html](https://github.com/CMTA/CMTAT/blob/master/doc/general/test/coverage/index.html)

Normally, you can run the code coverage with `npx hardhat coverage`

Please clone the repository and open the file inside your navigator

You will find a summary of all automatic tests in the file [test.pdf](https://github.com/CMTA/CMTAT/blob/master/doc/general/test/test.pdf)