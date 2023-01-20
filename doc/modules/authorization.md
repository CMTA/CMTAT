# Authorization Module

This document defines Authorization Module for the CMTA Token specification.

[TOC]



## Rationale

There are many operations that only authorized users are allowed to perform, such as issuing new tokens. Thus we need to manage authorization in a centralized way.
Authorization Module covers authorization use cases for the CMTA Token specification.

## API for Ethereum

### Functions

Origin: OpenZeppelin

#### `grantRole(bytes32,address)`

##### Signature:

```solidity
    function grantRole (bytes32 role, address account)
    public
```

##### Description:

Grant the given `role` to the given `account`.
Here the role is a keccak256 hash of the role name.
Only authorized users are allowed to call this function.

#### `revokeRole(bytes32,address)`

Origin: OpenZeppelin

##### Signature:

```solidity
    function revokeRole (bytes32 role, address account)
    public
```

##### Description:

Revoke from the given `role` from the given `account`.
Only authorized users are allowed to call this function.

#### `hasRole(bytes32,address)`

Origin: OpenZeppelin

##### Signature:

```solidity
    function hasRole (bytes32 role, address account)
    public view returns (bool)
```

##### Description:

Tell, whether the given `account` has the given `role` currently.

#### `hasRole(bytes32,address)`

Origin: OpenZeppelin

##### Signature:

```solidity
    function hasRole (bytes32 role, address account)
    public view returns (bool)
```

##### Description:

Tell, whether the given `account` has the given `role` currently.



### Events

#### `RoleGranted(bytes32,address,address)`

##### Signature:

```solidity
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender)
```

##### Description:

Emitted when the specified `account` was given the specified `role`.

#### `RoleRevoked(bytes32,address,address)`

##### Signature:

```solidity
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender)
```

##### Description:

Emitted when the the specified `role` was revoked from the specified `account`.
