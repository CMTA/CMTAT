# Validation RuleEngine Module

This document defines the Validation RuleEngine Module for the CMTA Token specification. The goal of this module is to use an external contract (`RuleEngine`) to check the validity of a transfer.

[TOC]



## Schema

### Inheritance

![surya_inheritance_ValidationModuleRuleEngine.sol](../../schema/surya_inheritance/surya_inheritance_ValidationModuleRuleEngine.sol.png)

### Graph

![surya_graph_ValidationModule.sol](../../schema/surya_graph/surya_graph_ValidationModuleRuleEngine.sol.png)



## API for Ethereum

This section describes the Ethereum API of the Validation Module.

The rules are defined using an (optional) rule engine, set using the `setRuleEngine` method. The `RuleEngine` implementation is not provided along with this implementation but it has to comply with the interface [IRuleEngine](https://github.com/CMTA/CMTAT/blob/master/contracts/interfaces/IRuleEngine.sol). The RuleEgine call rules that must respect the interface [IRule](https://github.com/CMTA/CMTAT/blob/master/contracts/interfaces/IRule.sol)

### Functions

#### `setRuleEngine(address)`

##### Definition:

```solidity
function setRuleEngine(IEIP1404Wrapper ruleEngine_) 
external onlyRole(DEFAULT_ADMIN_ROLE)
```

##### Description:

Set the optional rule engine to the given `address`.
Only authorized users are allowed to call this function.

### Events

#### `RuleEngine(address)`

##### Definition:

```solidity
event RuleEngine(IEIP1404Wrapper indexed newRuleEngine)
```

##### Description:

Emitted when the rule engine is set to `newRuleEngine`.
