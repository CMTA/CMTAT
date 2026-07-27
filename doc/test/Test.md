# CMTAT Test Catalogue

This file catalogues the CMTAT test suite **per feature module and per deployment version**, so that missing
coverage is easy to spot. It is a map, not a copy of the tests — it is maintained by hand and **must be updated
whenever a test is added, changed or removed** (see [Maintenance](#maintenance)).

- Run everything: `npm run test` (or `DeactivateReportGas=true npx hardhat test` if the gas reporter errors).
- Coverage report: `npm run coverage`.
- Scale: **~486 distinct `it(...)` definitions**, executed across the deployment variants for roughly **6 000
  test cases** (`5998 passing / 87 pending` on the current tree).

## Test architecture

CMTAT is a modular framework, and the tests mirror that. There are two layers:

1. **Shared behaviour modules** — `test/common/**` — each exports a function (e.g. `ERC20MintModuleCommon()`) that
   registers a `context(...)` of `it(...)` cases for one feature. These contain the actual assertions and are
   **deployment-agnostic**.
2. **Deployment wirings** — the shared modules are invoked against a concrete deployment:
   - `test/standard/modules/**` — one file per module, wired to the **standalone Standard** deployment.
   - `test/proxy/modules/**` — the same, wired to the **Transparent-proxy** deployment.
   - `test/deployment/<variant>/**` — one entry file per variant (standalone + upgradeable) that includes the
     subset of shared modules that variant supports, plus variant-specific inline tests.

So a single `it(...)` in `test/common/**` runs on every deployment version that includes its module. To find a
gap, ask: *does this module run on this version?* — the [coverage matrix](#coverage-matrix) answers that.

## Deployment versions

| Version | Base contract | Deploy helper (standalone / proxy) | Entry tests |
| --- | --- | --- | --- |
| **Light** | `CMTATBaseCore` | `deployCMTATLightStandalone` / `deployCMTATLightProxy` | `test/deployment/light/*` |
| **Standard** | `CMTATBaseERC7551Enforcement` | `deployCMTATStandalone` / `deployCMTATProxy` | `test/standard/modules/*`, `test/proxy/modules/*` |
| **Allowlist** | `CMTATBaseAllowlist` | `deployCMTATAllowlistStandalone` / `…Proxy` | `test/deployment/allowlist/*` |
| **ERC-7551** | `CMTATBaseERC7551` | `deployCMTATERC7551Standalone` / `…Proxy` | `test/deployment/erc7551/*` |
| **Permit** | `CMTATBaseERC2612` | `deployCMTATPermitStandalone` / `…Proxy` | `test/deployment/permit/*` |
| **Snapshot** | `CMTATBaseERC2771Snapshot` | `deployCMTATSnapshotStandalone` / `…Proxy` | `test/deployment/snapshot/*` |
| **Debt** | `CMTATBaseDebt` | `deployCMTATDebtStandalone` / `…Proxy` | `test/deployment/debt/*` |
| **DebtEngine** | `CMTATBaseDebtEngine` | `deployCMTATDebtEngineStandalone` / `…Proxy` | `test/deployment/debtEngine/*` |
| **HolderList** | `CMTATBaseHolderList` | `deployCMTATHolderListStandalone` / `…Proxy` | `test/deployment/…`, `test/{standard,proxy}/modules/HolderListModule*` |
| **ERC-1363** | `CMTATBaseERC1363` | `deployCMTATERC1363Standalone` / `…Proxy` | `test/deployment/ERC1363/*` |
| **UUPS** | `CMTATUpgradeableUUPS` | `deployCMTATUUPSProxy` | `test/deployment/deploymentUpgradeableUUPS*.test.js` |

> The **Standard** version is the reference: `test/standard/modules/**` and `test/proxy/modules/**` exercise the
> full module set (below). The other variants run the subset of modules they support.

## Coverage matrix

Which feature module runs on which deployment version. `✓` = the module's shared tests run on that version;
`—` = not applicable (the version does not include that feature); `(std)` = covered only via the full Standard /
Proxy module suites, not the variant entry file.

| Feature module (common) | Light | Standard | Allowlist | ERC-7551 | Permit | Snapshot | Debt | DebtEngine | ERC-1363 | UUPS |
| --- | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| Version | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Pause / Deactivate | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ERC20Base (transfer/approve/allowance) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ERC20Mint (mint/batchMint/batchTransfer) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ERC20Burn (burn/batchBurn/burnAndMint) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Enforcement (address freeze) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ERC20Enforcement (partial freeze / forcedTransfer) | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ERC20Enforcement ERC-7551 (bytes overloads) | — | ✓ | ✓ | ✓ | — | — | — | — | ✓ | — |
| Validation — Core (`canTransfer`, pause/freeze) | ✓ | ✓ | ✓ | (std) | (std) | (std) | ✓ | ✓ | (std) | (std) |
| Validation — RuleEngine (full, ERC-1404) | — | ✓ | — | (std) | (std) | (std) | — | — | (std) | (std) |
| Validation — RuleEngine reentrancy (NM-7) | — | ✓ | — | — | — | — | — | — | — | — |
| Allowlist | — | (std) | ✓ | — | — | — | — | — | — | — |
| Document (ERC-1643) | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| DocumentEngine | — | ✓ | — | — | — | — | — | — | — | — |
| ExtraInformation (tokenId/terms/info) | — | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ERC-7551 (metadata/terms overloads) | — | ✓ | — | ✓ | — | — | — | — | — | — |
| Snapshot (schedule/reschedule/unschedule/reads) | — | ✓ | — | — | — | ✓ | (engine) | (engine) | — | — |
| SnapshotEngine (setSnapshotEngine) | — | ✓ | — | — | — | ✓ | ✓ | ✓ | — | — |
| Debt (debt/creditEvents) | — | — | — | — | — | — | ✓ | (engine) | — | — |
| DebtEngine (setDebtEngine) | — | — | — | — | — | — | — | ✓ | — | — |
| CrossChain (ERC-7802 crosschainMint/Burn, burnFrom) | — | ✓ | — | ✓ | ✓ | ✓ | — | — | ✓ | ✓ |
| CCIP (setCCIPAdmin) | — | ✓ | — | ✓ | ✓ | ✓ | — | — | ✓ | ✓ |
| Permit (ERC-2612) | — | — | — | — | ✓ | — | — | — | — | — |
| Multicall (ERC-6357) | — | — | — | — | ✓ | — | — | — | — | — |
| MetaTx (ERC-2771, `_msgSender`/`_msgData`) | — | ✓ | ✓ (msgData) | — | — | ✓ (msgData) | — | — | ✓ (msgData) | ✓ (UUPS) |
| HolderList | — | ✓ | — | — | — | — | — | — | — | — |
| Authorization (RBAC grant/revoke) | (inline) | ✓ | (std) | (std) | (std) | (std) | (std) | (std) | (std) | (std) |
| CMTAT integration (end-to-end) | — | ✓ | — | — | — | — | — | — | — | — |

Notes:
- **Light** deliberately has the smallest surface: core ERC-20 + address-freeze + pause + core validation. It has
  **no** RuleEngine, partial-freeze, allowlist, document, snapshot, debt, cross-chain, permit or ERC-7551 tests —
  by design (see [`doc/technical/deployment.md`]). Light additionally has inline `forcedBurn` and ERC-165 tests in
  `test/deployment/light/*`.
- The **RuleEngine reentrancy** guard is only present on size-permitting variants (Standard, Snapshot, ERC-7551);
  `RuleEngineReentrancyCommon` is wired into the Standard standalone + proxy suites. See
  [`doc/modules/controllers/validationRuleEngine.md`] for the per-variant table.

## Test module reference

Each shared module (`test/common/**`), its `it(...)` count, and what it covers. Counts are indicative; the
scenarios list the `context(...)` groups.

### Core ERC-20 & supply
| Module | File | `it` | Covers |
| --- | --- | --: | --- |
| Version | `VersionModuleCommon.js` | 1 | `version()` returns the SemVer string. |
| ERC20Base | `ERC20BaseModuleCommon.js` | 25 | Token structure, name/symbol, decimals, balance, `approve`/allowance, `transfer`, `transferFrom`. |
| ERC20Mint | `ERC20MintModuleCommon.js` | 34 | `mint`, `batchMint`, `batchTransfer`; recipient-frozen blocks; **frozen minter can still mint** (`testFrozenMinterCanStillMint`/`…BatchMint`); frozen minter's `batchTransfer` blocked; RuleEngine spender propagation. |
| ERC20Burn | `ERC20BurnModuleCommon.js` | 30 | `burn`, `batchBurn`, `burnAndMint`. |

### Enforcement & validation
| Module | File | `it` | Covers |
| --- | --- | --: | --- |
| Enforcement | `EnforcementModuleCommon.js` | 21 | `setAddressFrozen`/`batchSetAddressFrozen`, `isFrozen`; frozen sender/spender/recipient block transfers; zero-address rejected; allowance revocation while frozen (NM-3/8). |
| ERC20Enforcement | `ERC20EnforcementModuleCommon.js` | 56 | `freezePartialTokens`/`unfreezePartialTokens`/`setFrozenTokens`; `forcedTransfer`/forced burn; active-balance checks; **`setFrozenTokens(address(0))` rejected + minting unaffected** (NM-15/17); **`forcedTransfer` emits `Spend` on the allowance reduction, none for zero/infinite** (NM-24). |
| ERC20Enforcement-7551 | `ERC20EnforcementERC7551ModuleCommon.js` | 4 | ERC-7551 `bytes`-data enforcement overloads. |
| Validation (Core) | `ValidationModule/ValidationModuleCommonCore.js` | 4 | `canTransfer`/`canTransferFrom` against pause + freeze, no RuleEngine. |
| Validation (RuleEngine) | `ValidationModule/ValidationModuleCommon.js` | 27 | RuleEngine transfer/transferFrom/mint gating, mint/burn frozen, send/receive checks (ERC-1404 + ERC-7943). |
| Validation setRuleEngine | `ValidationModule/ValidationModuleSetRuleEngineCommon.js` | 6 | `setRuleEngine` access control + same-value revert. |
| Validation reentrancy | `ValidationModule/RuleEngineReentrancyCommon.js` | 7 | Malicious reentrant RuleEngine cannot drain frozen tokens; guard reverts `ReentrancyGuardReentrantCall`; normal/batch flows unaffected (NM-7/9/11/16/18). |
| Allowlist | `AllowlistModuleCommon.js` | 36 | `setAddressAllowlist`/batch/`enableAllowlist`; allowlisted send/receive; `transferFrom` requires spender **and** from/to allowlisted (`testCannotTransferTokenWhenSpenderIsNotAllowlistWithTransferFrom`); **minter need not be allowlisted to mint** (`testMinterNotAllowlistedCanStillMint`/`…BatchMint`); approve while not allowlisted; revocation carve-out. |

### Documents, metadata, holder list
| Module | File | `it` | Covers |
| --- | --- | --: | --- |
| Document | `DocumentModule/DocumentModuleCommon.js` | 9 | ERC-1643 `setDocument`/`removeDocument`/`getDocument`. |
| DocumentEngine | `DocumentModule/DocumentModuleSetDocumentEngineCommon.js` | 10 | `setDocumentEngine`, initializer, delegated reads. |
| ExtraInformation | `ExtraInfoModuleCommon.js` | 8 | `setTokenId`/`setTerms`/`setInformation`. |
| ERC-7551 | `ERC7551ModuleCommon.js` | 6 | `setMetaData`, `setTerms(bytes32,string)`; **name-preserving overload** (`testERC7551SetTermsPreservesDocumentName`, NM-22). |
| HolderList | `HolderListModuleCommon.js` | 24 | Holder enumeration, range reads, zero-address never added. |

### Snapshot
| Module | File | `it` | Covers |
| --- | --- | --: | --- |
| Snapshot scheduling | `SnapshotModuleCommon/SnapshotModuleCommonScheduling.js` | 11 | Schedule (optimized + not). |
| Snapshot rescheduling | `…/SnapshotModuleCommonRescheduling.js` | 11 | Reschedule. |
| Snapshot unscheduling | `…/SnapshotModuleCommonUnschedule.js` | 12 | Unschedule. |
| Snapshot get-next | `…/SnapshotModuleCommonGetNextSnapshot.js` | 4 | `getNextSnapshots`. |
| Snapshot global | `…/global/SnapshotModule{Multiple,OnePlanned,ZeroPlanned}*.js` | 8 | Balance-at-snapshot with 0/1/many planned. |
| SnapshotEngine | `…/SnapshotModuleSetSnapshotEngineCommon.js` | 6 | `setSnapshotEngine`, initializer. |

### Options: debt, cross-chain, permit, meta-tx
| Module | File | `it` | Covers |
| --- | --- | --: | --- |
| Debt | `DebtModule/DebtModuleCommon.js` | 5 | `debt`/`creditEvents` values. |
| Debt setDebtEngine | `DebtModule/DebtModuleSetDebtEngineCommon.js` | 4 | `setDebtEngine`. |
| DebtEngine | `DebtModule/DebtEngineModuleCommon.js` | 3 | Delegated debt reads via engine. |
| CrossChain | `ERC20CrossChainModuleCommon.js` | 32 | ERC-7802 `crosschainMint`/`crosschainBurn`, `burnFrom`, self-burn; `onlyTokenBridge`; RuleEngine spender propagation. |
| CCIP | `CCIPModuleCommon.js` | 3 | `setCCIPAdmin` access control. |
| Permit | `PermitModuleCommon.js` | 5 | ERC-2612 `permit` (valid, paused, frozen). ⚠️ *No zero-value permit revocation test yet — see AUDIT_NETHERMIND_IMP I-3.* |
| Multicall | `MulticallModuleCommon.js` | 2 | ERC-6357 batching. |
| MetaTx | `MetaTxModuleCommon.js` + `MetaTxMsgDataCommon.js` | 4 | ERC-2771 gasless (`_msgSender`), `_msgData` coverage. |

### Security, RBAC, integration, engines-as-mocks
| Module | File | `it` | Covers |
| --- | --- | --: | --- |
| Authorization | `AuthorizationModule/AuthorizationModuleCommon.js` | 5 | RBAC grant/revoke, admin-has-all-roles. |
| CMTAT integration | `CMTATIntegrationCommon.js` | 4 | End-to-end multi-module flows. |
| Proxy security | `test/proxy/general/Proxy.test.js` | — | Proxy init / front-running / storage. |
| Upgrade | `test/proxy/general/Upgrade*.test.js` | — | Transparent + UUPS upgrade paths. |
| RuleEngine stateful | `test/standard/modules/RuleEngineMockStatefulRule.test.js` | — | Stateful holder-tracking rule via `transferred`. |

## Deployment-specific & cross-cutting test files

Not everything is a shared module. These entry files add variant-specific or cross-cutting coverage:
- `test/deployment/deployment.test.js` — constructor/initializer parameter validation.
- `test/deployment/light/*` — Light inline: `forcedBurn` when frozen, ERC-165 interface set (no ERC-1404/1363).
- `test/deployment/allowlist/deploymentStandaloneDisableAllowlist.test.js` — allowlist-disabled behaviour.
- `test/deployment/debt/…DebtSnapshot`, `debtEngine/…Snapshot` — debt + snapshot combined.
- `test/deployment/ERC1363/deploymentERC1363ProxyValidation.test.js` — ERC-1363 + RuleEngine validation.
- `test/deployment/deploymentUpgradeableUUPSManual.test.js` — manual UUPS deployment.
- `test/standard/modules/MetaTx*` and `MetaTxMsgData*` — ERC-2771 across Allowlist / ERC-1363 / Snapshot / UUPS.
- `test/standard/modules/ValidationModule/ValidationModuleConstructor.test.js` — RuleEngine set at construction.

## How to find missing coverage

1. In the [coverage matrix](#coverage-matrix), a `—` where a feature *should* exist on a version is a gap
   (e.g. a new option added to Light but not tested there).
2. In the [module reference](#test-module-reference), any behaviour described in `doc/**` with no matching `it`
   is a gap. Known open example: **Permit zero-value revocation** (⚠️ above).
3. A new deployment variant needs its own entry file wiring the applicable shared modules **and** a new matrix
   column here.

## Maintenance

**This file is hand-maintained. Update it in the same change that touches the tests:**
- **Test added** → add/adjust the `it` count and scenario in the [module reference](#test-module-reference); if it
  covers a new feature, add a matrix row/column.
- **Test removed** → remove it here; if it was the only coverage of a behaviour, note the resulting gap.
- **New deployment variant** → add a [Deployment versions](#deployment-versions) row and a
  [coverage matrix](#coverage-matrix) column.
- **New shared module** → add it to the [module reference](#test-module-reference) and the matrix.

Keeping this current is what makes missing tests findable at a glance — an out-of-date catalogue is worse than
none.
