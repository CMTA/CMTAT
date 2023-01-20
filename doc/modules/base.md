# Base Module

This document defines Base Module for the CMTA Token specification.

[TOC]

## Rationale

The Base Module sets forth the basic functionalities a token must have to comply with the CMTAT framework, for tokens representing equity securities as well as tokens representing and debt securities. 

## API for Ethereum

### Functions

#### `setTokenId(string)`

##### Signature:

```solidity
function setTokenId(string memory tokenId_) public
```

##### Description:

Set the `token id` to the given `string`.
Only authorized users are allowed to call this function.

#### `setTerms(string)`

##### Signature:

```solidity
function setTerms(string memory terms_) public
```

##### Description:

Set the `terms` to the given `string`.
Only authorized users are allowed to call this function.

#### `setInformation(string)`

##### Signature:

```solidity
function setInformation(string memory information_)
```

##### Description:

Set the information` to the given `uint256`.
Only authorized users are allowed to call this function.

#### `setFlag(string)`

##### Signature:

```solidity
function setFlag(uint256 flag_)public
```

##### Description:

Set the `flag` to the given `uint256`.
Only authorized users are allowed to call this function.

#### `kill`

##### Signature:

```solidity
function kill() public onlyRole(DEFAULT_ADMIN_ROLE) onlyDelegateCall(deployedWithProxy)
```

##### Description:

Destroys the contract, send the remaining ethers to msg.sender

### Events

#### `TermSet(string)`

##### Signature:

```solidity
event TermSet(string indexed newTerm)
```

##### Description:

Emitted when the variable `terms` is set to `newTerm`.

#### `tokenIdSet`

##### Signature:

```solidity
event TokenIdSet(string indexed newTokenId);
```

##### Description:

Emitted when `tokenId` is set to `newTokenId`.

#### `InformationSet(string)`

##### Signature:

```solidity
event InformationSet(string indexed newInformation)
```

##### Description:

Emitted when the variable `information` is set to `newInformation`.

#### `FlagSet(uint256)`

##### Signature:

```solidity
event FlagSet(uint256 indexed newFlag)
```

##### Description:

Emitted when the variable `flag` is set to `newFlag`.
