# Validation Module

This document defines the Validation Module for the CMTA Token specification. The goal of the Validation Module is to restrict token transferability based on a set of rules applied to the token.

## API for Ethereum

This section describes the Ethereum API of the Validation Module.

The rules are defined using an (optional) rule engine, set using the `setRuleEngine` method. The `RuleEngine` implementation is not provided along with this implementation but it has to comply with the following interface:

```
interface IRuleEngine {

  function setRules(IRule[] calldata rules_) external;
  function ruleLength() external view returns (uint256);
  function rule(uint256 ruleId) external view returns (IRule);
  function rules() external view returns(IRule[] memory);

  function validateTransfer(
    address _from,
    address _to,
    uint256 _amount)
  external view returns (bool);

  function detectTransferRestriction (
    address _from,
    address _to,
    uint256 _value)
  external view returns (uint8);

  function messageForTransferRestriction (uint8 _restrictionCode) external view returns (string memory);
}
```

```
interface IRule {
  function isTransferValid(
    address _from, address _to, uint256 _amount)
  external view returns (bool isValid);

  function detectTransferRestriction(
    address _from, address _to, uint256 _amount)
  external view returns (uint8);

  function canReturnTransferRestrictionCode(uint8 _restrictionCode) external view returns (bool);

  function messageForTransferRestriction(uint8 _restrictionCode) external view returns (string memory);
}
```

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
