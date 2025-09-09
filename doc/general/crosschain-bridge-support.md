## Cross-chain bridge support

> With which bridge can the CMTAT be used?

We will analyze the following bridges: [CCIP](https://chain.link/cross-chain) by Chainlink, Optimism superchain, [LayerZero](https://layerzero.network) and [AxelarNetwork](https://www.axelar.network)

Generally, in term of implementation, it depends of the model to handle cross-chain token transfer. There are three main models: Burn & Mint, Lock & Mint, Lock & Unlock

- To use the burn / Mint, you must implement in the token the functions required and used by the bridge (typically burn and mint). 
- The model "lock and lock" is a little different from the first two models because it does not in principle require any particular implementation.
- Several bridges offers as an alternative to use a wrapper if the contract is not directly compatible with the bridge

[TOC]



3. 

## Axelar

### Register Existing Token (lock / unlock)

If you own an ERC-20 token on a single chain and want a wrapped, bridgeable version on other chains, you can register it as a [Canonical Interchain Token](https://docs.axelar.dev/dev/send-tokens/glossary/#canonical-interchain-token) using the [Interchain Token Factory contract](https://github.com/axelarnetwork/interchain-token-service/blob/main/contracts/InterchainTokenFactory.sol#L20). Each token can only be registered once as a canonical token on its “home chain”.

You can register your existing token directly via the contract or use the [ITS Portal](https://docs.axelar.dev/dev/send-tokens/interchain-tokens/no-code/) no-code solution. Take a look at the diagram below to understand the process of registering an existing token as a Canonical Interchain Token.

[https://docs.axelar.dev/dev/send-tokens/interchain-tokens/register-existing-token/](https://docs.axelar.dev/dev/send-tokens/interchain-tokens/register-existing-token/)

## LayerZero

There are two possibilities to use LayerZero with a CMTAT:

- Extend CMTAT with OFT
- Deploy an OFT Adapter to act as an intermediary lockbox for the token.

#### OFT

The first one is to add a module inside CMTAT to include the Omnichain Fungible Token (OFT) Standard; see  [github.com/LayerZero-Labs - OFT.sol](https://github.com/LayerZero-Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/oapp/contracts/oft/OFT.sol)

The Omnichain Fungible Token (OFT) Standard allows **fungible tokens** to be transferred across multiple blockchains without asset wrapping, middlechains, or liquidity pools.

##### Modifying CMTAT

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

Remarks:

`OFT.sol` implements the standard ERC20 OpenZeppelin implementation, so it is not compatible with CMTAT which uses the upgradeable version. See also [LayerZero-v2/pull/9](https://github.com/LayerZero-Labs/LayerZero-v2/pull/9)

The alternative is to inherit from [OFTCore](https://github.com/LayerZero-Labs/LayerZero-v2/blob/main/packages/layerzero-v2/evm/oapp/contracts/oft/OFTCore.sol) which is ERC-20 agnostic and implements the missing functions. 

See [OFT standard](https://docs.layerzero.network/v2/home/token-standards/oft-standard)

#### OFT Adapter

**OFT Adapter** works as an intermediary contract that handles sending and receiving deployed fungible tokens. For example, when transferring an ERC20 from the source chain (Chain A), the token will lock in the OFT Adapter, triggering a new token to mint on the destination chain (Chain B) via the peer OFT.

[OFT Adapter](https://docs.layerzero.network/v2/home/token-standards/oft-standard)

See [https://docs.layerzero.network/v2/home/token-standards/oft-standard#oft-adapter]( https://docs.layerzero.network/v2/home/token-standards/oft-standard#oft-adapter)

