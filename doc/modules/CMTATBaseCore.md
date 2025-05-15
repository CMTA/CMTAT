# CMTATBaseCore

This document defines the ERC20Burn Module for the CMTA Token specification.

[TOC]



## Rationale

> This function allows the issuer to destroy specific tokens that are recorded on a distributed ledger address. This function is meant to be used if the issuer cancels tokenized shares (e.g. if it reduces its share capital, if it has decided to have the shares in a different form (e.g. “simple” uncertificated securities within the meaning of Article 973c CO or paper certificates), or to comply with a court order requiring the cancellation of tokens pursuant to Article 973h CO).

## Schema

![CMTATBaseCore](../schema/uml/CMTATBaseCore.png)

### Inheritance

![surya_inheritance_BurnModule.sol](../schema/surya_inheritance/surya_inheritance_CMTATBaseCore.sol.png)



### Graph

![surya_graph_CMTATBaseCoreModule.sol](../schema/surya_graph/surya_graph_CMTATBaseCore.sol.png)

## API for Ethereum

This section describes the Ethereum API of Burn Module.

### Functions

#### `forceBurn(address,uint256,string)`

##### Definition

```solidity
function forceBurn(address account,uint256 amount,string memory reason) 
public onlyRole(BURNER_ROLE)
```

##### Description

Destroys a `value` amount of tokens from `account`, by transferring it to address(0).

##### Requirements

Only authorized users (*BURNER_ROLE*) are allowed to call this function.

#### Events

##### `Burn(address,uint,string)`

```solidity
event Burn(address indexed owner, uint256 amount, string reason)
```

Emitted when the specified `value` amount of tokens owned by `owner`are destroyed with the given `reason`

​    
