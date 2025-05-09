## Cross-chain bridge support

> With which bridge can the CMTAT be used?

We will analyze the three main bridges: [CCIP](https://chain.link/cross-chain) by Chainlink, [LayerZero](https://layerzero.network) and [AxelarNetwork](https://www.axelar.network)

Generally, in term of implementation, it depends of the model to handle cross-chain token transfer. There are three main models: Burn & Mint, Lock & Mint, Lock & Unlock

To use one of these models, you must implement in the token the functions required and used by the bridge (typically burn and mint). The model "lock and lock" is a little different from the first two models because it does not in principle require any particular implementation.

## Chainlink CCIP

CMTAT does not implement the `owner` or `getCCIPAdmin()`function required by CCIP to register CCIP token permissibleness.

See [docs.chain.link/ccip/concepts/cross-chain-tokens#requirements-for-cross-chain-tokens](https://docs.chain.link/ccip/concepts/cross-chain-tokens#requirements-for-cross-chain-tokens)

|                          |                                           | Implemented  | Module<br />if implemented         | Role             |      |      |      |
| ------------------------ | ----------------------------------------- | ------------ | ---------------------------------- | ---------------- | ---- | ---- | ---- |
| Register CCIP token      |                                           |              |                                    |                  |      |      |      |
|                          | owner                                     | No           |                                    |                  |      |      |      |
|                          | getCCIPAdmin                              | No           |                                    |                  |      |      |      |
| Burn & Mint Requirements |                                           |              |                                    |                  |      |      |      |
|                          | mint(address account, uint256 amount)     | Yes          | MintModule<br />(Core module)      | MINTER_ROLE      |      |      |      |
|                          | burn(uint256 amount)                      | NO           |                                    |                  |      |      |      |
|                          | decimals()                                | yes (ERC-20) | ERC20BaseModule<br />(Core module) |                  |      |      |      |
|                          | balanceOf(address account)                | yes (ERC-20) | OpenZeppelin inheritance           |                  |      |      |      |
|                          | burnFrom(address account, uint256 amount) | Yes          | ERC20BurnModule (Core module)      | BURNER_FROM_ROLE |      |      |      |



## Optimism superchain ERC-20

The SuperchainERC20 contract implements [ERC-7802](https://ethereum-magicians.org/t/erc-7802-crosschain-token-interface/21508) to enable asset interoperability within the Superchain.

Instead of wrapping assets, this mechanism effectively "teleports" tokens between chains in the Superchain. It provides users with a secure and capital-efficient method for transacting across chains.

#### Initiating message (source chain)

1. The user (or a contract) calls [`SuperchainTokenBridge.sendERC20`(opens in a new tab)](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/SuperchainTokenBridge.sol#L52-L78).
2. The token bridge calls [`SuperchainERC20.crosschainBurn`(opens in a new tab)](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/SuperchainERC20.sol#L37-L46) to burn those tokens on the source chain.
3. The source token bridge calls [`SuperchainTokenBridge.relayERC20`(opens in a new tab)](https://github.com/ethereum-optimism/optimism/blob/develop/packages/contracts-bedrock/src/L2/SuperchainTokenBridge.sol#L80-L97) on the destination token bridge. This call is relayed using [`L2ToL2CrossDomainMessenger`](https://docs.optimism.io/interop/message-passing). The call is *initiated* here, by emitting an initiating message. It will be executed later, after the destination chain receives an executing message to [`L2ToL2CrossDomainMessenger`](https://docs.optimism.io/interop/message-passing).

## Axelar

### Register Existing Token (lock / unlock)

If you own an ERC-20 token on a single chain and want a wrapped, bridgeable version on other chains, you can register it as a [Canonical Interchain Token](https://docs.axelar.dev/dev/send-tokens/glossary/#canonical-interchain-token) using the [Interchain Token Factory contract](https://github.com/axelarnetwork/interchain-token-service/blob/main/contracts/InterchainTokenFactory.sol#L20). Each token can only be registered once as a canonical token on its “home chain”.

You can register your existing token directly via the contract or use the [ITS Portal](https://docs.axelar.dev/dev/send-tokens/interchain-tokens/no-code/) no-code solution. Take a look at the diagram below to understand the process of registering an existing token as a Canonical Interchain Token.

https://docs.axelar.dev/dev/send-tokens/interchain-tokens/register-existing-token/









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