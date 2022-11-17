# Validation Module

This document defines the Validation Module for the CMTA Token specification. The goal of the Validation Module is to restrict token transferability based on a set of rules applied to the token.

## API for Ethereum

This section describes the Ethereum API of the Validation Module.

The rules are defined using an (optional) rule engine, set using the `setRuleEngine` method. The `RuleEngine` implementation is not provided along with this implementation but it has to comply with the interface [IRuleEngine](https://github.com/CMTA/CMTAT/blob/master/contracts/interfaces/IRuleEngine.sol). The RuleEgine call rules that must respect the interface [IRule](https://github.com/CMTA/CMTAT/blob/master/contracts/interfaces/IRule.sol)

### Functions

#### `setRuleEngine(address)`

##### Signature:

```solidity
    function setRuleEngine(address ruleEngine)
    public
```

##### Description:

Set the optional rule engine to the given `address`.
Only authorized users are allowed to call this function.

### Events

#### `RuleEngineSet(address)`

##### Signature:

```solidity
    event RuleEngineSet (address indexed newRuleEngine)
```

##### Description:

Emitted when the rule engine is set to `newRuleEngine`.
