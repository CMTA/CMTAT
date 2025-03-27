# FAQ

This FAQ is intended to developers familiar with smart contracts
development.

## Cross-chain bridge support

> With which bridge can the CMTAT be used?

We will analyze the three main bridges: [CCIP](https://chain.link/cross-chain) by Chainlink, [LayerZero](https://layerzero.network) and [AxelarNetwork](https://www.axelar.network)

Generally, in term of implementation, it depends of the model to handle cross-chain token transfer. There are three main models: Burn & Mint, Lock & Mint, Lock & Unlock

To use one of these models, you must implement in the token the functions required and used by the bridge (typically burn and mint). The model "lock and lock" is a little different from the first two models because it does not in principle require any particular implementation.

For example the interface for CCIP is available here: [github.com/smartcontractkit/ccip - ERC20/IBurnMintERC20.sol](https://github.com/smartcontractkit/ccip/blob/948882675ad1c6604d4b911071fc3881148abe66/contracts/src/v0.8/shared/token/ERC20/IBurnMintERC20.sol)

Axelar Network has also a similar behavior and requirement to create what they call a custom interchain token: https://docs.axelar.dev/dev/send-tokens/interchain-tokens/create-token#create-a-custom-interchain-token

We haven't done any testing but in principle the functions `burnFrom`and `mint` are available and compatible with the last CMTAT version, see [github.com/CMTA/CMTAT/blob/master/contracts/interfaces/ICCIPToken.sol](https://github.com/CMTA/CMTAT/blob/master/contracts/interfaces/ICCIPToken.sol).

For the public burn function, unfortunately, we currently have a reason argument in the function which is not compatible with bridges because their burn function only have two arguments (account and value): [github.com/CMTA/CMTAT - wrapper/core/ERC20BurnModule.sol#L32](https://github.com/CMTA/CMTAT/blob/master/contracts/modules/wrapper/core/ERC20BurnModule.sol#L32)

### Chainlink CCIP

For chainlink, the difficulty is that for the moment only tokens whitelisted by chainlink (e.g USDC) can use the bridge, which is not the case for Axelar Network.

The ERC-20 interface for CCIP is available here: [github.com/smartcontractkit/ccip - ERC20/IBurnMintERC20.sol](https://github.com/smartcontractkit/ccip/blob/948882675ad1c6604d4b911071fc3881148abe66/contracts/src/v0.8/shared/token/ERC20/IBurnMintERC20.sol)

### LayerZero

There are two possibilities to use LayerZero with a CMTAT:

The first one is to add a module inside CMTAT to include the Omnichain Fungible Token (OFT) Standard; see  [github.com/LayerZero-Labs - OFT.sol](https://github.com/LayerZero-Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/oapp/contracts/oft/OFT.sol)

### OFT

The Omnichain Fungible Token (OFT) Standard allows **fungible tokens** to be transferred across multiple blockchains without asset wrapping, middlechains, or liquidity pools.

#### Modifying CMTAT

This standard work by burning tokens on the source chain whenever an omnichain transfer is initiated, sending a message via the protocol and delivering a function call to the destination contract to mint the same number of tokens burned, creating a **unified supply** across both networks.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@layerzerolabs/lz-evm-oapp-v2/contracts/standards/oft/OFT.sol";

contract MyOFT is OFT {
    constructor(
        string _name, // token name
        string _symbol, // token symbol
        address _lzEndpoint, // LayerZero Endpoint address
        uint8 _localDecimals) // token decimals
        OFT(_name, _symbol, _localDecimals, _lzEndpoint) {}
}
```

See [OFT standard](https://docs.layerzero.network/v2/home/token-standards/oft-standard)

#### OFT standard

**OFT Adapter** works as an intermediary contract that handles sending and receiving deployed fungible tokens. For example, when transferring an ERC20 from the source chain (Chain A), the token will lock in the OFT Adapter, triggering a new token to mint on the destination chain (Chain B) via the peer OFT.

[OFT Adapter](https://docs.layerzero.network/v2/home/token-standards/oft-standard)

The second possibility is to deploy an OFT Adapter to act as an intermediary lockbox for the token.

See https://docs.layerzero.network/v2/home/token-standards/oft-standard#oft-adapter

More information in LayerZero documentation: [docs.layerzero.network/v2/developers/evm/oft/quickstart](



https://docs.layerzero.network/v2/home/token-standards/oft-standard

## Toolkit support

> Which is the main development tool you use ?

Since the sunset of Truffle by Consensys, we use Hardhat

Regarding [Foundry](https://book.getfoundry.sh/):

- All our tests are written in Javascript and migrating them to Foundry will require a lot of work
- The tests for the gasless module (MetaTx) would be difficult to write
  in Solidity, as Foundry requires, see [https://github.com/CMTA/CMTAT/blob/master/test/common/MetaTxModuleCommon.js](https://github.com/CMTA/CMTAT/blob/master/test/common/MetaTxModuleCommon.js)

-  The OpenZeppelin libraries that we use have their tests mainly written in JavaScript, which provides a good basis for our tests


>  Do you plan to fully support Foundry in the near future? 

For the foreseeable future, we plan to keep Hardhat  as the main
development and testing suite.


>  Can Truffle be used to run tests?

No. Since the version v.2.31 and the use of `custom errors`, the tests no longer work with Truffle.

You can only run the tests with `Hardhat`.


## Modules

> What is the reason the Snapshot module wasn't audited in version v2.3.0?

This module was left out of scope because it is not used yet (and not included in a default deployment) and will be subject to changes soon. 

> What is the status of [ERC1404](https://erc1404) compatibility?

We have not planned to be fully compatible with ERC1404 (which, in fact, is only an EIP at the time of writing). 
CMTAT includes the two functions defind by ERC1404, namely `detectTransferRestriction` and `messageForTransferRestriction`.
Thus CMTAT can provide the same functionality as ERC1404.

However, from a pure technical perspective, CMTAT is not fully compliant
with the ERC1404 specification, due the way it inherits the ERC20
interface. 


> Is the Validation module optional? 

Generally, for a CMTAT token, the Validation functionality is optional
from the legal perspective (please contact admin@cmta.ch for detailed
information).

However, in order to use the functions from the Pause and Enforcement modules, our CMTAT implementation requires the Validation module. Therefore, the Validation module is effectively required *in this implementation*. 

If you remove the Validation module and want to use the Pause or the
Enforcement module, you have to call the functions of modules inside the main contracts. It was initially the case but we have changed this behavior when addressing an issue reported by a security audit.
Here is an old version:
[https://github.com/CMTA/CMTAT/blob/ed23bfc69cfacc932945da751485c6472705c975/contracts/CMTAT.sol#L205](https://github.com/CMTA/CMTAT/blob/ed23bfc69cfacc932945da751485c6472705c975/contracts/CMTAT.sol#L205), and the relevant Pull [Request](https://github.com/CMTA/CMTAT/pull/153).


## Documentation

> What is the code coverage of the test suite?

A [code coverage report](https://github.com/CMTA/CMTAT/blob/master/doc/general/test/coverage/index.html) is available.

Normally, you can run the test suite and generate a code coverage report with `npx hardhat coverage`.

Please clone the repository and open the file inside your browser.
