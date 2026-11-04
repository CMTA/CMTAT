# Compilation files

Compilation files of each CMTAT release, for the contracts in `contracts/deployment`. Release candidates are not included.

| Version | Content |
| --- | --- |
| [v3.3.0](./v3.3.0) | `hardhat/deployment` and `foundry/deployment` artifacts, and `flatten` |
| [v3.1.0](./v3.1.0) | Hardhat artifacts in `deployment`, and `flatten` |
| [v3.0.0](./v3.0.0) | Hardhat artifacts in `deployment`, and `flatten` |

v3.3.0 was compiled with solc 0.8.38, EVM target `osaka`, 200 optimizer runs. The Hardhat and Foundry artifacts have the same runtime bytecode, apart from the metadata hash. The flattened files were generated with `npx hardhat flatten`.

To add a release, from the release commit:

```bash
npx hardhat compile --force
forge build --force --skip test --skip script
```

Then copy `artifacts/contracts/deployment` to `doc/compilation/<version>/hardhat/deployment` and, for each contract in `contracts/deployment`, the file `out/<Contract>.sol/<Contract>.json` to the same relative path under `doc/compilation/<version>/foundry/deployment`.
