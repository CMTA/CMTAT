# Deployment Model

Deployment contracts are in `contracts/deployment/`. Each feature set comes in both a standalone (immutable) and an upgradeable (proxy-compatible) variant.

## Summary

| Model | Description | Type | Contract |
|---|---|---|---|
| **Standard** | Core + extension modules, ERC-2771 + cross-chain support | Standalone | `CMTATStandardStandalone` |
| | | Upgradeable | `CMTATStandardUpgradeable` |
| **UUPS** | Same as Standard + UUPS proxy support | Upgradeable only | `CMTATUpgradeableUUPS` |
| **ERC-1363** | Standard + ERC-1363 payable token | Standalone | `CMTATStandaloneERC1363` |
| | | Upgradeable | `CMTATUpgradeableERC1363` |
| **Permit** | Standard + ERC-2612 Permit + ERC-6357 Multicall (no ERC-2771) | Standalone | `CMTATStandalonePermit` |
| | | Upgradeable | `CMTATUpgradeablePermit` |
| **Light** | Core modules only (no extensions) | Standalone | `CMTATStandaloneLight` |
| | | Upgradeable | `CMTATUpgradeableLight` |
| **Debt** | Standard + DebtModule (no ERC-2771, no ERC20CrossChain) | Standalone | `CMTATStandaloneDebt` |
| | | Upgradeable | `CMTATUpgradeableDebt` |
| **DebtEngine** | Standard + DebtEngineModule + ERC-1404 (no ERC-2771) | Standalone | `CMTATStandaloneDebtEngine` |
| | | Upgradeable | `CMTATUpgradeableDebtEngine` |
| **Allowlist** | Standard + AllowlistModule (no RuleEngine/ERC-1404, no ERC20CrossChain), with ERC-7551 enforcement functions | Standalone | `CMTATStandaloneAllowlist` |
| | | Upgradeable | `CMTATUpgradeableAllowlist` |
| **ERC-7551** | Standard + ERC7551Module | Standalone | `CMTATStandaloneERC7551` |
| | | Upgradeable | `CMTATUpgradeableERC7551` |
| **Snapshot** | Standard + SnapshotEngine support | Standalone | `CMTATStandaloneSnapshot` |
| | | Upgradeable | `CMTATUpgradeableSnapshot` |

## Standard Standalone

Use `CMTATStandardStandalone` (file: `CMTATStandalone.sol`) for a fully immutable deployment. Includes all core and extension modules (except Debt, Allowlist, UUPS), plus `ERC2771Module` and `ERC20CrossChain`.

## Upgradeable (Transparent / Beacon Proxy)

Use `CMTATStandardUpgradeable` (file: `CMTATUpgradeable.sol`) as the implementation contract behind a Transparent or Beacon proxy.

See [OpenZeppelin Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/) for proxy deployment tooling.

## UUPS Proxy

Use `CMTATUpgradeableUUPS` for a UUPS proxy. The upgrade logic is in the implementation contract itself.

**Security note**: There is no segregation between admin rights and the proxy upgrade authority. Compromise of `DEFAULT_ADMIN_ROLE` would allow swapping the implementation. Use a multisig or timelock.

## Light Version

Includes only core modules: mint, burn, freeze, pause. No extensions (no documents, no snapshots, no partial freeze). Adds `forcedBurn` so the admin can burn from frozen addresses (since `ERC20EnforcementModule` with `forcedTransfer` is not included).

## ERC-1363

[ERC-1363](https://eips.ethereum.org/EIPS/eip-1363) allows executing code on a recipient after a transfer or on a spender after approval, in a single transaction. Available as `CMTATStandaloneERC1363` and `CMTATUpgradeableERC1363`.

## Permit + Multicall

See [`permit-multicall.md`](./permit-multicall.md).

## Debt / DebtEngine

See [`debt.md`](./debt.md).

## Allowlist

See the [Allowlist module documentation](../modules/options/allowlist/allowlist.md).

## Factory

Factory contracts for Beacon, Transparent, and UUPS proxy deployments are maintained in a separate repository: [CMTAT Factory](https://github.com/CMTA/CMTATFactory).

| CMTAT version | CMTAT Factory |
|---|---|
| CMTAT v3.0.0 | [v0.2.0](https://github.com/CMTA/CMTATFactory/releases/tag/v0.2.0) (unaudited) |

## Other Token Types (ERC-721, ERC-1155)

To build a CMTAT-flavored ERC-721 or ERC-1155, extend `CMTATBaseGeneric`. A mock `ERC721MockUpgradeable` is available in `contracts/mocks/` as a reference.

## Storage (ERC-7201)

CMTAT implements [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201) for namespaced storage, making upgradeable storage layout predictable and collision-free.

| Module | Storage Variable | bytes32 Slot |
|---|---|---|
| AllowlistModuleInternal | `AllowlistModuleInternalStorageLocation` | `0x53076eaf2d1e2f915f2e0487c9f92cca686c37fd47bf11f95f0da313b2809800` |
| EnforcementModuleInternal | `EnforcementModuleInternalStorageLocation` | `0x0c7bc8a17be064111d299d7669f49519cb26c58611b72d9f6ccc40a1e1184e00` |
| ERC20EnforcementModuleInternal | `ERC20EnforcementModuleStorageLocation` | `0x9d8059a24cb596f1948a937c2c163cf14465c2a24abfd3cd009eec4ac4c39800` |
| ERC20BaseModule | `ERC20BaseModuleStorageLocation` | `0x9bd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00` |
| PauseModule | - | `0xab1527b6135145d8da1edcbd6b7b270624e17f2b41c74a8c746ff388ad454700` |
| DocumentEngineModule | `DocumentEngineModuleStorageLocation` | `0xbd0905600c85d707dc53eba2e146c1c2527cd32ac3ff6b86846155151b3e2700` |
| ExtraInformationModule | `ExtraInformationModuleStorageLocation` | `0xd2d5d34c4a4dea00599692d3257c0aebc5e0359176118cd2364ab9b008c2d100` |
| SnapshotEngineModule | `SnapshotEngineModuleStorageLocation` | `0x1387b97dfab601d3023cb57858a6be29329babb05c85597ddbe4926c1193a900` |
| CCIPModule | `CCIPModuleStorageLocation` | `0x364fbfd89c0eee55bbc8dd10b1a9bf3e04fba9f3ee606f4c79a82f9941ad7a00` |
| DebtModule | `DebtModuleStorageLocation` | `0xf8a315cc5f2213f6481729acd86e55db7ccc930120ccf9fb78b53dcce75f7c00` |
| ERC7551Module | `ERC7551ModuleStorageLocation` | `0x2727314c926b592b6f70e7d6d2e4677ebcac070f293306927f71fe77858eec00` |

## Initialize Functions

Each upgradeable module exposes `__{ContractName}_init_unchained`. Call these in your proxy initializer instead of `__{ContractName}_init` to avoid double-initialization across the inheritance chain.

See [OpenZeppelin - Multiple Inheritance](https://docs.openzeppelin.com/contracts/5.x/upgradeable#multiple-inheritance) for details.
