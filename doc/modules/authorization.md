# Authorization Module

This document defines Authorization Module for the CMTA Token specification.

## Rationale

There are many operations that only authorized users are allowed to perform, such as issuing new tokens. Thus we need to manage authorization in a centralized way.
Authorization Module covers authorization use cases for the CMTA Token specification.

## API for Ethereum

### Functions

#### `authorize(address,bytes32)`

##### Signature:

    function authorize (address user, bytes32 action)
    public

##### Description:

Authorize the given `user` to perform the given `action`.
Here action is usually a keccak256 hash of the action name and, optionally, the action parameters.
Only authorized users are allowed to call this function.

#### `unauthorize(address,bytes32)`

##### Signature:

    function unauthorize (address user, bytes32 action)
    public

##### Description:

Revoke from the given `user` the authorization to perform the given `action`.
Only authorized users are allowed to call this function.

#### `authorized(address,bytes32)`

##### Signature:

    function authorized (address user, bytes32 action)
    public view returns (bool)

##### Description:

Tell, whether the given `user` is currently authorized to perform the given `action`.

### Events

#### `Authorization(address,bytes32`

##### Signature:

    event Authorization (address indexed user, bytes32 indexed action)

##### Description:

Emitted when the specified `user` was authorized to perform the specified `action`.

#### `AuthorizationRevocation(address,bytes32`

##### Signature:

    event Authorization (address indexed user, bytes32 indexed action)

##### Description:

Emitted when the authorization to perform the specified `action` was revoked from the specified `user`.
