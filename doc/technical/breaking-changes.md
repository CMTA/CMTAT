# Breaking changes

This document details the **breaking changes** between:

1. **v3.2.0 → v3.3.0** (previous release → current release);
2. **v3.0.0 → v3.3.0** (last audited release, by Halborn → current release).

It uses the CHANGELOG definition of the `breaking change` tag: a change to the **ERC-7201 storage namespaces** or to
the **external engines** (RuleEngine, SnapshotEngine, DocumentEngine, DebtEngine). These are the changes that can
silently break an **upgraded proxy** or an **existing engine contract**. Public API changes (renamed functions,
events, errors) are summarized at the end of each part and detailed in the [CHANGELOG](../../CHANGELOG.md).

All findings were checked against the code: storage layouts and engine interfaces were compared directly between
the git tags `v3.0.0`, `v3.1.0`, `v3.2.0` and the v3.3.0 code, and the module set of every deployment variant was
computed from its inheritance graph.

[TOC]

---

## Part 1 — v3.2.0 → v3.3.0

### 1.1 Summary

| # | Change | Type | Affected variants | Effect on a v3.2.0 proxy upgraded to v3.3.0 | Action |
| --- | --- | --- | --- | --- | --- |
| S1 | `name` / `symbol` moved to a new namespace | Storage | All, including Light | `name()` / `symbol()` return empty strings | Re-set them atomically during the upgrade (§1.2.1) |
| S2 | Documents stored in the token instead of an external DocumentEngine | Storage + engine | All except Light | Documents of the old engine are no longer visible; `setDocumentEngine` / `documentEngine` removed | Re-register the documents with `setDocument` (§1.2.2) |
| S3 | SnapshotEngine support removed from several variants | Storage + engine | Standard, UUPS, ERC-1363, ERC-7551, Allowlist | The SnapshotEngine **stops receiving transfer callbacks**, so its snapshots silently become wrong | Upgrade to the Snapshot variant, or do not upgrade (§1.2.3) |
| E1 | RuleEngine receives the operator on supply operations | Engine | Variants with a RuleEngine | `mint`, `burn`, `burnFrom`, minter `batchTransfer` and cross-chain mint/burn now call the 4-argument `transferred(spender, from, to, value)` instead of the 3-argument one | Check the engine's spender rules (§1.3.1) |
| E2 | RuleEngine callback under a reentrancy guard | Engine | Standard, Snapshot, ERC-7551 | An engine that calls back into a guarded token function from `transferred` reverts | Remove the callback (§1.3.2) |
| E3 | DocumentEngine interface (`IERC1643`) changed | Engine | Contracts built on `DocumentEngineModule` (no shipped variant) | A v3.2.0 DocumentEngine is not ABI-compatible | Use DocumentEngine v0.4.0 (§1.3.3) |
| E4 | Engine interfaces require Solidity `^0.8.24` | Engine (compile time) | Engines importing the CMTAT interfaces | Compilation fails with an older compiler | Compile with Solidity ≥ 0.8.24 |

### 1.2 Storage

ERC-7201 namespaces in v3.3.0 that differ from v3.2.0:

| Namespace | v3.2.0 | v3.3.0 |
| --- | --- | --- |
| `CMTAT.storage.ERC20BaseModule` (`0x9bd8d607…3a00`) | `uint8 _decimals; string _name; string _symbol;` | `uint8 _decimals;` (trailing fields removed) |
| `CMTAT.storage.TokenAttributeModule` (`0xc541cfc0…6d00`) | — | `string _name; string _symbol;` **(new)** |
| `CMTAT.storage.DocumentERC1643Module` (`0x24fbb1cf…a200`) | — | `mapping(bytes32 => Document) _documents; mapping(bytes32 => uint256) _documentKey; bytes32[] _documentNames;` **(new)** |
| `CMTAT.storage.DocumentEngineModule` (`0xbd090560…2700`) | used by every variant except Light | layout unchanged, **no longer used by any shipped variant** |
| `CMTAT.storage.SnapshotEngineModule` (`0x1387b97d…`) | used by every variant except Light | layout unchanged, used only by Snapshot, Debt and DebtEngine |
| `CMTAT.storage.HolderListModule` (`0x93edd371…ca00`) | — | `EnumerableSet.AddressSet _holders;` **(new, HolderList variant only)** |

All other namespaces (Pause, Enforcement, ERC20Enforcement, Allowlist, ValidationModuleRuleEngine, ExtraInformation,
ERC7551, Debt, DebtEngine, CCIP) are unchanged.

#### 1.2.1 S1 — `name` / `symbol` (all variants)

The new core module `TokenAttributeModule` owns `name` / `symbol` in `CMTAT.storage.TokenAttributeModule`. The old
values stay at `ERC20BaseModule` slots `+1` / `+2`, but nothing reads them anymore. `decimals` does not move.

After a plain upgrade, `name()` and `symbol()` return empty strings, which breaks wallets, explorers and any EIP-712
signer (the `permit` domain uses the name).

**Migration.** Restore the two values **in the same transaction** as the upgrade (`upgradeToAndCall` for UUPS,
`ProxyAdmin.upgradeAndCall` for Transparent), by calling a `reinitializer(n)` function of the new implementation.

A reference implementation is provided in `contracts/mocks/upgrade/`:

- `CMTATV33TokenAttributeMigration` reads `name` / `symbol` from their v3.2.0 location (`ERC20BaseModule` slots `+1`
  / `+2`) and clears those slots. Because the values are read on-chain, the migration takes no argument and cannot be
  fed wrong values.
- `CMTATStandardUpgradeableV33MigrationMock` and `CMTATUpgradeableSnapshotV33MigrationMock` add
  `migrateFromV32()` (`reinitializer(2)`), which writes the values with `__TokenAttributeModule_init_unchained`.

These contracts are mocks: review and adapt them (target variant, reinitializer version) before production use. The
`reinitializer` version `n` must be higher than any version the proxy has already used. Calling `setName` /
`setSymbol` after the upgrade also works, but leaves the token with an empty name between the two transactions.

The procedure is tested against a real v3.2.0 proxy in `test/proxy/general/UpgradeFromV320.test.js`, which also
checks S2 and S3 below.

#### 1.2.2 S2 — documents (all variants except Light)

| | v3.2.0 | v3.3.0 |
| --- | --- | --- |
| Module | `DocumentEngineModule` (delegates to an external DocumentEngine) | `DocumentERC1643Module` (documents stored in the token) |
| Engine functions | `setDocumentEngine`, `documentEngine` | **removed** |
| Document name | `string` | `bytes32` |
| `getDocument` return | `Document` struct | `(string uri, bytes32 documentHash, uint256 lastModified)` |
| Write functions on the token | none (written on the engine) | `setDocument`, `removeDocument` (`DOCUMENT_ROLE`) |

After an upgrade the token reads documents from its own, empty storage: documents held by the previous DocumentEngine
are no longer returned. The engine address remains in `CMTAT.storage.DocumentEngineModule` but is unused.

**Migration.** Before the upgrade, export the documents with the old engine's `getAllDocuments()` /
`getDocument(string)`. After the upgrade, register each one with `setDocument(bytes32 name, string uri, bytes32
documentHash)`:

- Names longer than 32 bytes must be shortened or mapped to a `bytes32` identifier.
- `lastModified` is reset to the block of the `setDocument` call.
- Integrators reading documents must switch to the `bytes32` API and listen to `DocumentUpdated` /
  `DocumentRemoved` on the token itself.

#### 1.2.3 S3 — SnapshotEngine removed from several variants

Module set by variant (computed from the inheritance graph):

| Variant | v3.2.0 SnapshotEngine | v3.3.0 SnapshotEngine |
| --- | :---: | :---: |
| Standard (`CMTATStandalone` / `CMTATUpgradeable` → `CMTATStandardStandalone` / `CMTATStandardUpgradeable`) | ✔ | ✘ |
| UUPS (`CMTATUpgradeableUUPS`) | ✔ | ✘ |
| ERC-1363 | ✔ | ✘ |
| ERC-7551 | ✔ | ✘ |
| Allowlist | ✔ | ✘ |
| Debt | ✔ | ✔ |
| DebtEngine | ✔ | ✔ |
| Snapshot (**new**) | — | ✔ |
| Permit, HolderList (**new**) | — | ✘ |
| Light | ✘ | ✘ |

This is the most dangerous item because **nothing reverts**. After upgrading, for example, a v3.2.0 Standard proxy
to the v3.3.0 Standard implementation, the token no longer calls `snapshotEngine.operateOnTransfer` on transfers,
mints and burns. The SnapshotEngine keeps answering queries, but from stale data, so every snapshot taken after the
upgrade (dividends, corporate actions) is wrong.

**Migration.**

- **Standard proxy using a SnapshotEngine** → upgrade to `CMTATUpgradeableSnapshot` instead of
  `CMTATStandardUpgradeable`. The `CMTAT.storage.SnapshotEngineModule` namespace is unchanged, so the configured engine
  is kept and nothing needs to be re-set.
- **UUPS, ERC-1363, ERC-7551 or Allowlist proxy using a SnapshotEngine** → v3.3.0 has no equivalent variant. Stay on
  v3.2.0, or build a custom variant that composes `CMTATBaseSnapshot`.
- Proxies that never set a SnapshotEngine are not affected; the unused engine slot stays empty.

### 1.3 External engines

#### 1.3.1 E1 — RuleEngine receives the operator on supply operations

The token calls the RuleEngine through `ValidationModuleRuleEngine._transferred`. It calls
`transferred(spender, from, to, value)` when `spender != address(0)`, and the legacy
`transferred(from, to, value)` otherwise.

| Operation | v3.2.0 `spender` | v3.2.0 engine call | v3.3.0 `spender` | v3.3.0 engine call |
| --- | --- | --- | --- | --- |
| `transfer` | `address(0)` | 3-arg | `address(0)` | 3-arg |
| `transferFrom` | `msg.sender` | 4-arg | `msg.sender` | 4-arg |
| `mint` / `batchMint` | `address(0)` | 3-arg | **operator** | **4-arg** |
| `burn` / `batchBurn` | `address(0)` | 3-arg | **operator** | **4-arg** |
| `batchTransfer` (minter) | `address(0)` | 3-arg | **operator** | **4-arg** |
| `burnFrom`, cross-chain `burn`, `crosschainMint`, `crosschainBurn` | `address(0)` | 3-arg | **operator** | **4-arg** |

Impact on an engine:

- An engine that only implemented meaningful logic in the 3-arg overload for mints (`from == address(0)`) and burns
  (`to == address(0)`) must now handle these cases in the 4-arg overload.
- Spender rules now apply to minters, burners and bridges. For example, a rule requiring the spender to be
  allowlisted or not frozen will block a mint by an operator that does not satisfy it.

The `canTransfer` / `canTransferFrom` views are unchanged.

#### 1.3.2 E2 — reentrancy guard on the `transferred` callback

On the variants with bytecode headroom (Standard, Snapshot, ERC-7551), `_callRuleEngineTransferred` runs under
OpenZeppelin `ReentrancyGuardTransient` (EIP-1153). The guard uses transient storage, so it adds **no persistent
storage**. An engine whose `transferred` calls back into a guarded token function (for example to move tokens) now
reverts on these variants. On the other variants the engine remains a trusted component; this is documented, not enforced.

#### 1.3.3 E3 — DocumentEngine interface (`IERC1643`)

| v3.2.0 | v3.3.0 |
| --- | --- |
| `getDocument(string name) returns (Document)` | `getDocument(bytes32 name) returns (string uri, bytes32 documentHash, uint256 lastModified)` |
| `getAllDocuments() returns (string[])` | `getAllDocuments() returns (bytes32[])` |
| — | `setDocument(bytes32, string, bytes32)`, `removeDocument(bytes32)` |
| — | events `DocumentUpdated`, `DocumentRemoved`; errors `ERC1643MissingDocument`, `ERC1643InvalidName` |

Only contracts that still use `DocumentEngineModule` are concerned; no shipped v3.3.0 variant does. The compatible
engine is DocumentEngine v0.4.0.

#### 1.3.4 Unchanged engines

- **SnapshotEngine** (`ISnapshotEngine`): interface unchanged. Only the variants that call it changed (S3).
- **DebtEngine** (`IDebtEngine`): interface and namespace unchanged.

### 1.4 Upgrade checklist (v3.2.0 proxy → v3.3.0)

1. **Pick the target variant.** `CMTATUpgradeable` is now `CMTATStandardUpgradeable`. If the proxy uses a
   SnapshotEngine, target `CMTATUpgradeableSnapshot` instead, or stay on v3.2.0 (S3).
2. **Before the upgrade, export the state that will be lost:** `name()`, `symbol()`, and every document
   (`getAllDocuments` / `getDocument` on the old DocumentEngine).
3. **Upgrade and restore `name` / `symbol` in one transaction** (S1).
4. **Re-register the documents** with `setDocument` (S2).
5. **If a RuleEngine is set,** check its 4-arg `transferred` path and spender rules against the new mint / burn
   dispatch (E1), and make sure it does not call back into the token (E2).
6. **Run the OpenZeppelin upgrades validation** (`validateUpgrade`) between the two implementations, and test the
   upgrade on a fork first. `test/proxy/general/UpgradeFromV320.test.js` shows the full sequence on a real v3.2.0
   proxy.

### 1.5 Public API changes (outside the tag)

These do not affect storage or engines but break integrators and ABIs. Details are in the CHANGELOG
(`3.3.0 - rc0` to `rc3`):

- ERC-7943: `canTransact` → `canSend` / `canReceive`; `ERC7943CannotTransact` → `ERC7943CannotSend` /
  `ERC7943CannotReceive`; interface id `0x29388973` → `0x3edbb4c4`.
- ERC-1643 token API: `bytes32` document names, flat `getDocument` return.
- ERC-7551 event `Enforcement(...)` → `ForcedTransfer(operator, from, to, value, data)`.
- `ICMTATDeactivate` → `IERC8343` (same interface id `0xe9cd80b0`).
- Deployment contracts renamed: `CMTATStandalone` / `CMTATUpgradeable` → `CMTATStandardStandalone` /
  `CMTATStandardUpgradeable`.
- New ERC-165 ids advertised: ERC-1643 (`0xecfecec8`), ERC-1404 (`0xab84a5c8`), ERC-1404 extension (`0x78a8de7d`).

---

## Part 2 — v3.0.0 (audited) → v3.3.0

### 2.1 Summary by release

| Release | Breaking changes (storage / engines) |
| --- | --- |
| **v3.1.0** | **None.** New `CCIPModule` namespace (additive). The terms struct was renamed `Terms` → `CMTATTerms` with the same fields, so the layout is unchanged. Engine interfaces unchanged. |
| **v3.2.0** | D1 — DebtEngine address moved to a new namespace and to a new variant. R1 — RuleEngine interface split and ERC-165. I1 — engines removed from constructors / `initialize`. |
| **v3.3.0** | S1, S2, S3, E1, E2, E3, E4 (Part 1). |

An upgrade from v3.0.0 to v3.3.0 must handle **all** the items of v3.2.0 and v3.3.0. The v3.2.0 items are detailed below.

### 2.2 v3.2.0 items

#### 2.2.1 D1 — DebtEngine (storage + engine)

| | v3.0.0 / v3.1.0 | v3.2.0 / v3.3.0 |
| --- | --- | --- |
| Debt variant | `DebtModule` + `DebtEngineModule` | `DebtModule` only |
| DebtEngine support | Debt variant | new **DebtEngine** variant (`CMTATStandaloneDebtEngine` / `CMTATUpgradeableDebtEngine`) |
| Engine address storage | trailing field `_debtEngine` of `DebtModuleStorage` in `CMTAT.storage.DebtModule` | `CMTAT.storage.DebtEngineModule` (`0xcd6e7f8f…6d00`) |

The on-chain debt data (`_debt`, `_creditEvents`) stays in `CMTAT.storage.DebtModule`. The engine address does not
follow: after an upgrade, the token no longer reaches the DebtEngine.

**Migration.**

- A v3.0.0 Debt proxy **using a DebtEngine** → upgrade to `CMTATUpgradeableDebtEngine` and call `setDebtEngine`
  again (`DEBT_ENGINE_ROLE`).
- A v3.0.0 Debt proxy storing debt data on-chain → upgrade to `CMTATUpgradeableDebt`; the data is kept.

The `IDebtEngine` interface itself is unchanged.

#### 2.2.2 R1 — RuleEngine interface (engine)

| v3.0.0 | v3.2.0 / v3.3.0 |
| --- | --- |
| `IRuleEngine is IERC1404Extend, IERC7551Compliance, IERC3643IComplianceContract` | `IRuleEngine is IERC7551Compliance, IERC3643IComplianceContract, IERC165` |
| — | `IRuleEngineERC1404 is IERC1404Extend, IRuleEngine` |

- An engine must now implement `supportsInterface` (ERC-165, `RULE_ENGINE_INTERFACE_ID = 0x20c49ce7`).
- An engine used by a variant exposing ERC-1404 (Standard, UUPS, ERC-1363, ERC-7551, DebtEngine, Snapshot,
  HolderList, Permit) must implement `IRuleEngineERC1404`. The token casts the engine to it in
  `detectTransferRestriction`, `detectTransferRestrictionFrom` and `messageForTransferRestriction`, and must forward
  a non-empty message for every code it returns (see [ruleengine-integration.md](./ruleengine-integration.md)).
- The function signatures called by the token are unchanged, so an existing deployed engine keeps working at the
  ABI level. The changes matter when (re)compiling an engine against the CMTAT interfaces.

#### 2.2.3 I1 — engines removed from initialization (engine)

DocumentEngine and SnapshotEngine are no longer constructor / `initialize` parameters (#343). For a **fresh**
deployment, set them after deployment (`setSnapshotEngine`; there is no `setDocumentEngine` in v3.3.0, see S2).
Deployment scripts and factories must be updated. Already-initialized proxies are not affected.

### 2.3 Variant mapping (v3.0.0 → v3.3.0)

| v3.0.0 variant | v3.3.0 target | Breaking items to handle |
| --- | --- | --- |
| `CMTATStandalone` / `CMTATUpgradeable` | `CMTATStandardStandalone` / `CMTATStandardUpgradeable`, or `…Snapshot` if a SnapshotEngine is used | S1, S2, S3, E1, E2 |
| `CMTATUpgradeableUUPS` | `CMTATUpgradeableUUPS` (no snapshot support) | S1, S2, S3, E1 |
| `CMTATStandaloneERC1363` / `CMTATUpgradeableERC1363` | same names (no snapshot support) | S1, S2, S3, E1 |
| `CMTATStandaloneERC7551` / `CMTATUpgradeableERC7551` | same names (no snapshot support) | S1, S2, S3, E1, E2 |
| `CMTATStandaloneAllowlist` / `CMTATUpgradeableAllowlist` | same names (no snapshot, no RuleEngine) | S1, S2, S3 |
| `CMTATStandaloneDebt` / `CMTATUpgradeableDebt` with a DebtEngine | `…DebtEngine` | D1, S1, S2, E1 |
| `CMTATStandaloneDebt` / `CMTATUpgradeableDebt` without a DebtEngine | `…Debt` | S1, S2, E1 |
| `CMTATStandaloneLight` / `CMTATUpgradeableLight` | same names | S1 |

R1, I1, E3 and E4 concern the engine code and deployment scripts rather than a given proxy.

### 2.4 Upgrade checklist (v3.0.0 proxy → v3.3.0)

1. Apply the **v3.2.0 items** first:
   - D1: choose the Debt or DebtEngine target, and plan `setDebtEngine`.
   - R1: make sure the RuleEngine implements ERC-165 and, for ERC-1404 variants, `IRuleEngineERC1404`.
2. Apply the **v3.3.0 checklist** (§1.4): target variant, export of `name` / `symbol` and documents, atomic restore,
   document re-registration, RuleEngine dispatch review.
3. Validate the storage layout with the OpenZeppelin upgrades plugin (`validateUpgrade` v3.0.0 → v3.3.0) and test the
   upgrade on a fork. Because several changes are silent (S1 empty strings, S2 missing documents, S3 stale snapshots),
   assert `name()`, `symbol()`, `getAllDocuments()`, `debtEngine()` and `snapshotEngine()` after the upgrade.

### 2.5 Public API changes (outside the tag)

In addition to §1.5, between v3.0.0 and v3.2.0 (details in the CHANGELOG):

- **v3.1.0:**
  - `BaseModule` renamed `VersionModule` (`IERC3643Base` → `IERC3643Version`).
  - Cross-chain functions moved to `ERC20CrossChainModule`, and `crosschainBurn` / `burnFrom` follow the ERC-7802 /
    Superchain allowance model.
  - `IERC7551Mint` / `IERC7551Burn` extend ERC-5679.
  - ERC-7551 `setTerms` emits `Terms`.
- **v3.2.0:**
  - ERC-7943 support (`setFrozenTokens`, `canTransact`, which was replaced again in v3.3.0).
  - Transfers revert with specific errors when paused / deactivated.
  - `approve` reverts while paused (all variants except Light).
  - The `Errors` library was removed; errors moved to their interfaces and some were renamed.
