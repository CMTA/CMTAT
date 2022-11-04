# CHANGELOG

Please follow <https://changelog.md/> conventions.

## 2.0 - 20221104

This version is not fully ready to be used with a proxy, see issues [58](https://github.com/CMTA/CMTAT/issues/58) and [66](https://github.com/CMTA/CMTAT/issues/66)

This version contains breaking changes with the version 1.0

- Updated OpenZeppelin contracts upgradeable to the version v4.7.3,
  precisely this
  [commit](https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/tree/7567bcbabead3bae4bfb3d908bf0d0a7cee6809e).
- Solidity version updated to `^0.8.17`.
- Updated all libraries in package.json, exception for eth-sig-util which has not been updated.
- Set the `trustedForwarder` as immutable to be compatible with OpenZeppelin ([commit](https://github.com/CMTA/CMTAT/commit/56004748744448dac9faa089ef1e8ab5e8cc6d5c))
- Each test is performed with and without a proxy
  ([commit](https://github.com/CMTA/CMTAT/commit/de3596f4c6b32a9f9614b038e6db7ddddadbfb40)).
- Improved documentation by adding a summary of the audit, a description
  of the access control, an UML diagram of the project.

This version also includes improvements suggested by the audit report,
addressing the following findings:

- CVF 7, 9 and 10: removed useless return value in
  `_unscheduleSnapshot`, `_rescheduleSnapshot`, `_scheduleSnapshot`
  ([commit
  CVF-7](https://github.com/CMTA/CMTAT/commit/ff0deee3c7d978ef39ac5eb240f428888b3963d5),
  [commit
  CVF-9](https://github.com/CMTA/CMTAT/commit/b8148542b3812f8b0133d971cf82dc854e5fcebc),
  [commit
  CVF-10](https://github.com/CMTA/CMTAT/commit/1ea4a2ddf2215d98d4ea7c4fca5fe1304a6aa517)).
- CVF-27, 48, 55: used an `enum` to store the restriction code
  ([commit](https://github.com/CMTA/CMTAT/commit/4a8246dcb16dedcab7380ecc55eb38643355c76e)).
- CVF-40: defined event for `setTokenId` and `setTerms`
  ([commit](https://github.com/CMTA/CMTAT/commit/d845a97490a02f3f2284060a6a763f266f4f9ae7)).
- Fix CVF-56: renamed message for the constant
  `TEXT_TRANSFER_REJECTED_FROZEN`
  ([commit](https://github.com/CMTA/CMTAT/commit/6b16e738b613679876a8f465e78171bd27185060)).
- CVF-66, CVF-69, CVF-70, CVF-72, which created two new interfaces:
  `IERC1404` and `IERC1404Wrapper`
  ([commit](https://github.com/CMTA/CMTAT/commit/62c946b654f05b581c7774eda41c67ca9b10e3bf)).


## 1.0 - 20211005

- Added CMTAT equity token core functionalities 
- Added support for OpenGSN gasless transactions
- Added support for proxy deployment
- Added ABDK security audit report
- Added initial API documentation

## 0.1 - 20191120

- Legacy CMTA20 contract
