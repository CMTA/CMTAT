# Supply management

|                                                        | burn      | batchBurn | burnFrom        | mint      | batchMint | crosschain burn | Crosschain mint | forcedTransfer   |
| ------------------------------------------------------ | --------- | --------- | --------------- | --------- | --------- | --------------- | --------------- | ---------------- |
| Module                                                 | ERC20Burn | ERC20Burn | ERC20CrossChain | ERC20Mint | ERC20Mint | ERC20CrossChain | ERC20CrossChain | ERC20Enforcement |
| Module type                                            | Core      | Core      | Options         | Core      | Core      | Options         | Options         | Extensions       |
| frozen address                                         | &#x2612;  | &#x2612;  | &#x2612;        | &#x2612;  | &#x2612;  | &#x2612;        | &#x2612;        | &#x2611;         |
| Unfreeze missing funds if active balance is not enough | &#x2612;  | &#x2612;  | &#x2612;        | -         | -         | &#x2612;        | -               | &#x2611;         |
| Call the RuleEngine                                    | &#x2611;  | &#x2611;  | &#x2611;        | &#x2611;  | &#x2611;  | &#x2611;        | &#x2611;        | &#x2612;         |



## Burn



