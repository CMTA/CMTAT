# Specification

The transfer of token from an address to another address is restricted by using the ERC-1404, *Simple Restricted Token Standard* 
See [ethereum/EIPs/issues/1404](https://github.com/ethereum/EIPs/issues/1404), [erc1404.org/](https://erc1404.org/).
We have added one function to the standard : `isTransferValid`
- The interface `RuleEngine` is the main contract, it manages the different rules to apply to a transfer.
- The interface `IRule` defines the standard form of a rule.

The following UML describes the different interfaces and their function.

![alt text](./UML.svg)
