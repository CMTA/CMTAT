# Snapshot Module

This document defines the Snapshot Module for the CMTA Token specification. 

This module allows to set a specific engine called `SnapshotEngine`to perform snapshot on-chain. 

[TOC]

## Rationale

> In relation to distributions or the exercise of rights attached to tokenized securities, it is necessary to determine the number of tokens held by certain users at a certain point in time to allow issuers to carry out certain corporate actions such as dividend or interest payments. 
>
> Such moments are generally referred to in practice as the "record date" or the "record time" (i.e. the time that is relevant to determine the eligibility of security holders for the relevant corporate action). 
>
> The snapshot functions to determine the number of tokens recorded on the various ledger addresses at a specific point in time and to use that information to carry out transactions on-chain.

## Schema

![snapshotUML](../../../schema/uml/snapshotUML.png)

### Inheritance

![surya_inheritance_ERC20SnapshotModule.sol](../../../schema/surya_inheritance/surya_inheritance_SnapshotEngineModule.sol.png)



### Graph



![surya_graph_ERC20SnapshotModule.sol](../../../schema/surya_graph/surya_graph_SnapshotEngineModule.sol.png)

### API Ethereum

#### ISnapshotEngineModule

Minimal interface for configuring a snapshot engine module.

#### Events

------

##### `SnapshotEngine(ISnapshotEngine newSnapshotEngine)`

Emitted when a new snapshot engine is set.

| Parameter           | Type              | Description                                             |
| ------------------- | ----------------- | ------------------------------------------------------- |
| `newSnapshotEngine` | `ISnapshotEngine` | Address of the newly assigned snapshot engine contract. |



------

#### Errors

------

##### `CMTAT_SnapshotModule_SameValue()`

Reverts if the new snapshot engine is the same as the current one.

------

#### Functions

------

##### `setSnapshotEngine(ISnapshotEngine snapshotEngine_)`

Sets the address of the snapshot engine contract.

| Parameter         | Type              | Description                                      |
| ----------------- | ----------------- | ------------------------------------------------ |
| `snapshotEngine_` | `ISnapshotEngine` | The new snapshot engine contract address to set. |



**Requirements:**

- Reverts with `CMTAT_SnapshotModule_SameValue` if the same engine is provided.
- Emits a `SnapshotEngine` event.

------

##### `snapshotEngine() → ISnapshotEngine`

Returns the currently active snapshot engine.

| Returns          | Type              | Description                                   |
| ---------------- | ----------------- | --------------------------------------------- |
| `snapshotEngine` | `ISnapshotEngine` | Address of the currently set snapshot engine. |
