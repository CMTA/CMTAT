# Document Module

This document defines  Document Module for the CMTA Token specification.

[TOC]

## Schema

![DocumentUML](../../../schema/uml/DocumentUML.png)

### Inheritance

![surya_inheritance_DebtBaseModule.sol](../../../schema/surya_inheritance/surya_inheritance_DocumentEngineModule.sol.png)





### Graph

![surya_graph_DebtBaseModule.sol](../../../schema/surya_graph/surya_graph_DocumentEngineModule.sol.png)

## Ethereum API

### getDocument(string)

Return a document identified by its name

```solidity
function getDocument(string memory name) 
public view  virtual 
returns (Document memory document)
```



### getAllDocuments()

Return all documents

```solidity
function getAllDocuments() public view virtual 
returns (string[] memory documents)
```

