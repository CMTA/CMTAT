### Guideline

If you create a version for another blockchain, feel free to use this summary tab to build a correspondence table between CMTAT framework, CMTAT Solidity version and your implementation.

#### CMTAT framework

In the below table, the CMTAT framework required features are mapped to Solidity features.

| **CMTAT framework mandatory functionalities** | **CMTAT Solidity corresponding features**                    |
| --------------------------------------------- | ------------------------------------------------------------ |
| Know total supply                             | ERC20 `totalSupply`                                          |
| Know balance                                  | ERC20 `balanceOf`                                            |
| Transfer tokens                               | ERC20 `transfer`                                             |
| Create tokens (mint)                          | `Mint/batchMint`                                             |
| Cancel tokens (force burn)                    | `burn/batchBurn`<br />*(Nb. we recommend to have a dedicated function to burn tokens without the token holder consent or from a frozen address*) |
| Pause tokens                                  | Pause <br />(*Nb. With CMTAT Solidity it is still possible to burn and mint while transfers are paused.)* |
| Unpause tokens                                | `unpause`                                                    |
| Deactivate contract                           | `deactivateContract`                                         |
| Freeze                                        | `setAddressFrozen` (previously `freeze`)                     |
| Unfreeze                                      | `setAddressFrozen` (previously `unfreeze`)                   |
| Name attribute                                | ERC20 `name` attribute                                       |
| Ticker symbol attribute                       | ERC20 `symbol` attribute                                     |
| Token ID attribute                            | `tokenId`                                                    |
| Reference to legally required documentation   | `terms` (document name, hash and uri with at least the uri)  |

**Freeze** 

To be compatible with [ERC-3643](https://eips.ethereum.org/EIPS/eip-3643), the freeze functionality is implemented with only one function: `setAddressFrozen` which takes the target address and the frozen status (true/false).

However, for non-EVM blockchains, it could be clearer and make more sense to separate the freeze and unfreeze (or `thaw`) functionality with two separate and distinct functions, such as: 

```solidity
freeze(address targetAddress)
unfreeze(address targetAddress)
```

#### CMTAT extended 

In the below table, the CMTAT framework extendedfeatures are mapped to Solidity features.

| CMTAT Functionalities                | **CMTAT Solidity corresponding features**      | CMTAT Allowlist                                              | CMTAT Light                                                  | CMTAT Debt                                                   | CMTAT Standard                                               |
| ------------------------------------ | ---------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| On-chain snapshot                    | `snapshotModule & snapshotEngine`              | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> |
| Forced Transfer                      | `forcedTransfer`                               | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> |
| Forced burn                          | `forcedBurn`                                   | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> |
| Freeze partial token                 | `freezePartialTokens`/ `unfreezePartialTokens` | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> |
| Integrated whitelisting/allowlisting | CMTAT Allowlist                                | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> |
| External Whitelisting/allowlisting   | CMTAT with rule whitelist                      | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> |
| RuleEngine / transfer hook           | CMTAT with RuleEngine                          | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> |
| Upgradibility                        | CMTAT Upgradeable version                      | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> |
| Feepayer/gasless                     | CMTAT with ERC-2771 module                     | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #b00020;">&#x2718;</span></strong> | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> |

**ForcedBurn/forcedTransfer:** 

In the standard burn function, it is not possible to burn token from a frozen wallet.  CMTAT offers a dedicated function `forcedTransfer`which allows to force a transfer or a burn. If the `forcedTransfer` function is not available, the alternative is to implement only the function `forcedBurn`. 

This is what is done for the CMTAT light version which does not include `forcedTransfer`. You can also decide to implement both. In this case, we suggest that only `forcedBurn`can burn tokens and not `forcedTransfer`. With the CMTAT Solidity version, when `forcedTransfer` is available, we do not implement `forcedBurn` to reduce smart contract code size, but this limitation is not necessarily present with other blockchains.

#### Implementation details

| Functionalities                                | **CMTAT Solidity**                                           | Note                                                         |
| ---------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Mint while pause                               | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | Dedicated crosschain mint (e.g. `crosschainMint`) cannot be performed while the contract is in the pause state. |
| Burn while pause                               | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | Dedicated crosschain burn (e.g.`crosschainBurn`) cannot be performed while the contract is in the pause state. |
| Self Burn                                      | <strong><span style="color: #b00020;">&#x2718;</span></strong> | Token holder can not burn their own tokens.<br />Only authorised addresses are allowed to burn tokens. |
| Standard burn on a frozen address              | <strong><span style="color: #b00020;">&#x2718;</span></strong> | Required to use `forcedTransfer` or `forcedBurn`             |
| Burn tokens with the function `forcedTransfer` | <strong><span style="color: #1e7e34;">&#x2714;</span></strong> | See note above                                               |

**Self burn**

It's deliberate that only the issuer (and not the tokenholder) can burn a token, and that this corresponds to a legal requirement in several countries.

Indeed, once issued, a security can only be cancelled by its issuer, not by its holder. Since the token serves as a vehicle for the security, the same must apply to the token itself. An investor wishing to "get rid of" a token must transfer it to the issuer, who can then cancel it when the law allows.

However, feel free to add it in your CMTAT version if this makes sense for you from a legal or business perspective.