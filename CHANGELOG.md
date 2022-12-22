# CHANGELOG

Please follow <https://changelog.md/> conventions.

## 2.1 - 20221216

This version is not audited

This version contains breaking changes with the version 2.0.

- BurnModule

  - Replace the function *burnFrom* by the function *forceBurn* to permit the issuer (BURNER_ROLE) to burn tokens.
  - The versions CMTAT 1.0 and 2.0 do not strictly respect the CMTAT specification because you can only burn tokens if the sender (with the BURNER_ROLE) has the allowance on the tokens.
  - CMTAT 2.0 does not strictly respect the CMTAT specification because you can not force transfer or make an equivalent operation (burn tokens, then mint tokens to a new address).
- Proxy
  - Add a boolean to indicate if the contract is deployed with or without a proxy. 
  - Add a call to the function *disableInitializers* to prevent the implementation contract from being used.
  - Add a protection on the function kill by adding the module *OnlyDelegateCallModule*.

Others changes

- Proxy

  - Add initializers function in all contracts when they miss.

  - Add storage gaps in all contracts when they miss.

- OpenZeppelin
  - Updated OpenZeppelin contracts upgradeable to the version v4.8.0, precisely this [commit](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/tree/65420cb9c943c32eb7e8c9da60183a413d90067a).

  - Replace *setupRole* (deprecated) by *grantRole* in the function *CMTAT_init_unchained*.
- Improve the modularity of the architecture

  - Separate internal implementation from wrappers.
  - Separate mandatory and optional modules.
  - Move the BaseModule inside the mandatory directory.
  - Separate ERC20 functions from BaseModule by creating a specific module ERC20BaseModule.
  - Move the functions kill, setTokenId, setTerms from CMTAT.sol to BaseModule.
  - Move the functions pause & unpause  from CMTAT.sol to PauseModule.
  - Move the functions freeze & unfreeze from CMTAT.sol to EnforcementModule.
- Improve tests and their documentation of AuthorizationModule, BaseModule, BurnModule, EnforcementModule, MintModule and ValidationModule.

This version also includes improvements suggested by the audit report, addressing the following findings:

- CVF-2, CVF-46, CVF-49, CVF-53, CVF-57, CVF-60, CVF-62:  indicate the OpenZeppelin version in the file USAGE.md ([Commit](https://github.com/CMTA/CMTAT/commit/c0e257671144cf87bd33f241b3e208cfc374e45c)).

- CVF-29: perform a call to the *ERC165_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/3ade86b3c18857ff87a37e910f8855552d1a1065)).

- CVF-30: call *ERC20_init_unchained* before *Base_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/b3a96c917be7386a17bb170e2f9d90fabd3caffb)).
- CVF-35: specify which base contract is called instead of using the keyword *super* ([commit 1](https://github.com/CMTA/CMTAT/commit/38ec85df464fc8162e9214b2d308170d2de2d4fb), [commit 2](https://github.com/CMTA/CMTAT/commit/a6a8ca1bc0b974d0d1d63bc0f42e112d5f243b19)).

- CVF-47: define the functions *PauseModule_init* & *PauseModule_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/7a2735bec1d1dc1192f48303c8ce21f001747466)).
- CVF-51: define the functions *Authorization_init* & *Authorization_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/7a2735bec1d1dc1192f48303c8ce21f001747466)).
- CVF 52: move the mint functionality inside the MintModule ([commit](https://github.com/CMTA/CMTAT/commit/1a620f1f0ab29e2d2e1e3c6471c24c882d5c562d)).
- CVF-61: second part, define the functions *BurnModule_init* & *BurnModule_init_unchained* ([commit](https://github.com/CMTA/CMTAT/commit/7a2735bec1d1dc1192f48303c8ce21f001747466)).

## 2.0 - 20221104

This version is not fully ready to be used with a proxy, see issues [58](https://github.com/CMTA/CMTAT/issues/58) and [66](https://github.com/CMTA/CMTAT/issues/66)

This version contains breaking changes with the version 1.0

- Updated OpenZeppelin contracts upgradeable to the version v4.7.3, precisely this [commit](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/commit/0a2cb9a445c365870ed7a8ab461b12acf3e27d63).
- Solidity version updated to `^0.8.17`.
- Updated all libraries in package.json, exception for eth-sig-util which has not been updated.
- Set the `trustedForwarder` as immutable to be compatible with OpenZeppelin ([commit](https://github.com/CMTA/CMTAT/commit/56004748744448dac9faa089ef1e8ab5e8cc6d5c))
- Each test is performed with and without a proxy
  ([commit](https://github.com/CMTA/CMTAT/commit/de3596f4c6b32a9f9614b038e6db7ddddadbfb40)).
- Improved documentation by adding a summary of the audit, a description
  of the access control, an UML diagram of the project.

This version also includes improvements suggested by the audit report,
addressing the following findings:

- CVF-7, CVF-9 and CVF-10: removed useless return value in
  `_unscheduleSnapshot`, `_rescheduleSnapshot`, `_scheduleSnapshot`
  ([commit CVF-7](https://github.com/CMTA/CMTAT/commit/ff0deee3c7d978ef39ac5eb240f428888b3963d5), [commit CVF-9](https://github.com/CMTA/CMTAT/commit/b8148542b3812f8b0133d971cf82dc854e5fcebc), [commit CVF-10](https://github.com/CMTA/CMTAT/commit/1ea4a2ddf2215d98d4ea7c4fca5fe1304a6aa517)).
- CVF-27, 48, 55: used an `enum` to store the restriction code ([commit](https://github.com/CMTA/CMTAT/commit/4a8246dcb16dedcab7380ecc55eb38643355c76e)).
- CVF-40: defined event for `setTokenId` and `setTerms` ([commit](https://github.com/CMTA/CMTAT/commit/d845a97490a02f3f2284060a6a763f266f4f9ae7)).
- Fix CVF-56: renamed message for the constant`TEXT_TRANSFER_REJECTED_FROZEN` ([commit](https://github.com/CMTA/CMTAT/commit/6b16e738b613679876a8f465e78171bd27185060)).
- CVF-66, CVF-69, CVF-70, CVF-72, which created two new interfaces:`IERC1404` and `IERC1404Wrapper` ([commit](https://github.com/CMTA/CMTAT/commit/62c946b654f05b581c7774eda41c67ca9b10e3bf)).


## 1.0 - 20211005

- Added CMTAT equity token core functionalities 
- Added support for OpenGSN gasless transactions
- Added support for proxy deployment
- Added ABDK security audit report
- Added initial API documentation

## 0.1 - 20191120

- Legacy CMTA20 contract
