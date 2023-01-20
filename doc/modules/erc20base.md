# Base Module

This document defines Base Module for the CMTA Token specification.

## Rationale

The ERC20Base Module sets forth the ERC20 basic functionalities a token must have to  be a fungible token circulating on a blockchain.



## API for Ethereum

Base Module API for Ethereum blockchain extends the [ERC-20](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) API, the standard fungible token API for Ethereum.

### Functions

#### `totalSupply()`

##### Signature:

```solidity
    function totalSupply ()
    public view returns (uint)
```

##### Description:

Return the total number of tokens currently in circulation.

#### `balanceOf(address)`

##### Signature:

```solidity
    function balanceOf (address owner)
    public view returns (uint)
```

##### Description:

Return the number of tokens currently owned by the given `owner`.

#### `transfer(address,uint)`

##### Signature:

```solidity
    function transfer (address destination, uint amount)
    public returns (bool)
```

##### Description:

Transfer the given `amount` of tokens from the caller to the given `destination` address.
The function returns `true` on success and reverts on error.

#### `approve(address,uint)`

##### Signature:

```solidity
    function approve (address spender, uint amount)
    public returns (bool)
```

##### Description:

Allow the given `spender` to transfer at most the given `amount` of tokens from the caller.
The function returns `true` on success and reverts of error.

#### `approve(address,uint,uint)`

##### Signature:

```solidity
    function approve (address spender, uint amount, uint currentAllowance)
    public returns (bool)
```

##### Description:

Allow the given `spender` to transfer at most the given `amount` of tokens from the caller.
The function may be successfully executed only when the given `currentAllowance` values equals to the amount of token the spender is currently allowed to transfer from the caller.
The function returns `true` on success and reverts of error.

This function in not defined by ERC-20 and is needed to safely change the allowance.  Consider the following scenario:

1. Alice allows Bob to transfer 100 of her tokens
2. Alice wants to allow Bob to transfer 10 more of her tokens, i.e. 110 of her tokens in total
3. Alice calls `approve (bob, 110)`
4. Bob front runs the Alice's transaction with his own call: `transferFrom (alice, bob, 100)`
5. Bob's transaction transfers 100 tokens from Alice to Bob and reduces the allowance to zero
6. Then Alice's transaction is executed and sets the allowance to 110
7. No Bob executes `transferFrom (alice, bob, 110)` and takes another 110 tokens from Alice

So, Bob got 210 tokens in total, while Alice never means to allow him to transfer more than 110 tokens.

In order to mitigate this kind of attack, Alice at step 3 calls `approve (bob, 110, 100)`.  Such call could only succeed if the allowance is still 100, i.e. Bob's attempt to front run the transaction will make Alice's transaction to fail.

#### `allowance(address,address)`

##### Signature:

```solidity
    function allowance (address owner, address spender)
    public view returns (uint)
```

##### Description:

Return the number of tokens the given `spender` is currently allowed to transfer from the given `owner`.

#### `transferFrom(address,address,uint)`

##### Signature:

```solidity
    function transferFrom (address owner, address destination, uint amount)
    public returns (bool)
```

##### Description:

Transfer the given `amount` of tokens from the given `owner` to the given `destination` address.
`sender` and `recipient` cannot be the zero address.
The function returns `true` on success and reverts of error.

### Events

#### `Transfer(address,address,uint)`

##### Signature:

```solidity
    event Transfer (address indexed origin, address indexed destination, uint amount)
```

##### Description:

Emitted when the specified `amount` of tokens was transferred from the specified `origin` address to the specified `destination` address.

#### `Approval(address,address,uint)`

##### Signature:

```solidity
    event Approval (address indexed owner, address indexed spender, uint amount)
```

##### Description:

Emitted when the specified `owner` allowed the specified `spender` to transfer the specified `amount` of tokens.

#### `Spend(address,address,uint)`

##### Signature:

```solidity
    event Spend (address indexed owner, address indexed spender, uint amount)
```

#### Description:

Emitted when the specified `spender` spends the specified `amount` of the tokens owned by the specified `owner` reducing the corresponding allowance.

This event is not defined by ERC-20 and is needed to track allowance changes.
