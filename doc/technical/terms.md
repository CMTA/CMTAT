# Terms in CMTAT Light — analysis and refactoring plan

> Status: **planned for v3.4.0, not implemented yet.**
> Analysis based on branch `v3.3.0-final` (HEAD `658672f`), compared with tags `v3.0.0`, `v3.1.0`, `v3.2.0` and `v2.5.1`.

[TOC]

## 1. Summary

- **Light has no `terms`** because `terms` lives in `ExtraInformationModule`, an **extension**, and Light
  (`CMTATBaseCore`) is defined as "core modules only". Light also has no `tokenId` or `information`, for the same reason.
- **This has been the case in every v3 release.** `v3.0.0`, `v3.1.0`, `v3.2.0` and the current `v3.3.0` code all
  lack `terms` in Light. Before v3 there was no Light variant.
- **No document says why `terms` in particular was left out.** It happened as a side effect of the v3.0.0-rc.0
  refactor, which moved `terms` out of the core `BaseModule` and into an extension. The docs record that the field
  is missing (`doc/technical/stablecoin.md`), but they do not record the reason.
- **This conflicts with the CMTA framework mapping.** `terms` (*"Reference to legally required documentation"*)
  is a **mandatory** functionality of the CMTAT framework, so Light does not cover a mandatory item, and no
  document mentions this gap. `tokenId` is **not** mandatory. `doc/technical/cmtat-specification-analyse.md` now
  and `doc/README.md` (§ *CMTAT framework*) say this explicitly. Every document that describes Light now states that
  it lacks the mandatory `terms`.
- **Proposed fix:** move `terms` into a new core `TermsModule` with its **own ERC-7201 namespace**
  (`CMTAT.storage.TermsModule`, `_terms` at offset 0). `ExtraInformationModule` inherits from it, and every variant
  reads and writes terms in that single location. `CMTATBaseCore` (Light) also inherits `TermsModule`.
- **Target release: v3.4.0.** Upgrade cost: every proxy deployed before v3.4.0 must copy its terms to the new
  namespace with a one-time `reinitializer`. For a proxy coming from before v3.3.0, the same reinitializer also
  performs the v3.3.0 `name`/`symbol` migration.
- **Storage breaks are allowed**, but the remaining compatibility measures (a zero-cost
  placeholder slot and an optional migration helper) are kept because removing them gains nothing and risks silent
  data corruption (§4.2.5).

---

## 2. Current state (v3.3.0)

### 2.1 Where `terms` lives

`contracts/modules/wrapper/extensions/ExtraInformationModule.sol`

```solidity
// keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ExtraInformationModule")) - 1)) & ~bytes32(uint256(0xff))
bytes32 private constant ExtraInformationModuleStorageLocation = 0xd2d5d34c4a4dea00599692d3257c0aebc5e0359176118cd2364ab9b008c2d100;

struct ExtraInformationModuleStorage {
    string _tokenId;      // slot base + 0
    CMTATTerms _terms;    // slot base + 1 .. base + 4
    string _information;  // slot base + 5
}
```

`CMTATTerms` = `{ string name; IERC1643.Document doc }` and `IERC1643.Document` = `{ string uri; bytes32 documentHash; uint256 lastModified }`,
so the slot layout is:

| Slot (from namespace base) | Field |
| --- | --- |
| `base + 0` | `_tokenId` |
| `base + 1` | `_terms.name` |
| `base + 2` | `_terms.doc.uri` |
| `base + 3` | `_terms.doc.documentHash` |
| `base + 4` | `_terms.doc.lastModified` |
| `base + 5` | `_information` |

What the module contains for terms:

| Item | Kind |
| --- | --- |
| `terms()` | public view (`ICMTATBase`) |
| `setTerms(IERC1643CMTAT.DocumentInfo)` | public, `onlyExtraInfoManager` → `EXTRA_INFORMATION_ROLE` |
| `_setTerms(DocumentInfo)` / `_setTerms($, DocumentInfo)` | internal |
| `_setTermsDocument(bytes32, string)` | internal, used by `ERC7551Module.setTerms(bytes32,string)` (NM-22: keeps the name) |
| `event Terms(CMTATTerms)` | `ICMTATBase` |
| `__ExtraInformationModule_init_unchained(tokenId, terms, information)` | initializer |

The interface `ICMTATBase` (`contracts/interfaces/tokenization/ICMTAT.sol`) declares the `CMTATTerms` struct, the
`Terms` / `TokenId` / `Information` events and all six getters/setters together.

### 2.2 Who uses `ExtraInformationModule`

| Consumer | How |
| --- | --- |
| `0_CMTATBaseCommon` | inherits `ExtraInformationModule` |
| `0_CMTATBaseGeneric` | inherits it, calls `__ExtraInformationModule_init_unchained`, `_authorizeExtraInfoManagement` → `EXTRA_INFORMATION_ROLE` |
| `2_CMTATBaseAccessControl` | calls the init, `_authorizeExtraInfoManagement` → `EXTRA_INFORMATION_ROLE` |
| `8_CMTATBaseERC7551` | overrides `_authorizeExtraInfoManagement` (diamond with `CMTATBaseAccessControl`) |
| `wrapper/options/ERC7551Module` | inherits it; uses `_setTermsDocument`, `terms()` (for `termsHash()`) |
| `0_CMTATBaseCore` (**Light**) | **does not inherit it** |

### 2.3 Light (`CMTATBaseCore`)

`CMTATBaseCore` inherits `VersionModule`, `ERC20MintModule`, `ERC20BurnModule`, `ValidationModuleAllowance`,
`ERC20BaseModule`, `TokenAttributeModule`, `AccessControlModule` and some interfaces. Its initializer is
`initialize(address admin, ICMTATConstructor.ERC20Attributes)`, with no `ExtraInformationAttributes`.

What the docs say about this:

- `doc/technical/stablecoin.md:56`: *"no `extraInformationAttributes_` (no tokenId/terms/information)"*.
- `doc/technical/stablecoin.md:97`: *"On-chain token metadata | `ExtraInformationModule` | No `tokenId`, `terms`, `information` fields."*,
  listed under *"intentionally absent to keep the contract lean"*.
- `doc/README.md:191` / `:2637`: Light = *"core features … without additional functions required by equities and
  debt instruments (e.g., document management, snapshot, partial freeze of balances)"*. `terms` is **not** listed
  there as an excluded feature.
- `doc/test/Test.md:70`: the ExtraInformation row is `—` for Light.

---

## 3. History: was `terms` already missing in v3.2.0, v3.1.0 and v3.0.0?

**Yes. Light has never included `terms`.** Checked with `git show <tag>:contracts/modules/0_CMTATBaseCore.sol` and
`…/deployment/light/CMTATStandaloneLight.sol`:

| Version | Light exists | `CMTATBaseCore` inheritance (relevant part) | Light constructor / initialize | `terms` in Light |
| --- | --- | --- | --- | --- |
| v2.5.1 | ✘ (no Light variant) | — | — | n/a. `terms` was a plain `string` in **core** `BaseModule`, together with `tokenId` and `information` |
| **v3.0.0** | ✔ | `BaseModule` (VERSION only), Mint, Burn, `ValidationModuleCore`, `ERC20BaseModule`, `AccessControlModule` | `(admin, ERC20Attributes)` | ✘ |
| **v3.1.0** | ✔ | `VersionModule`, Mint, Burn, `ValidationModuleCore`, `ERC20BaseModule`, `AccessControlModule`, `IERC5679` | `(admin, ERC20Attributes)` | ✘ |
| **v3.2.0** | ✔ | same as v3.1.0 + `IERC7943FungibleTransferError` | `(admin, ERC20Attributes)` | ✘ |
| v3.3.0 (HEAD) | ✔ | + `TokenAttributeModule`, `ValidationModuleAllowance` | `(admin, ERC20Attributes)` | ✘ |

Origin: in `CHANGELOG.md` § *3.0.0-rc.0 – 2025-05-13*, the same release that:

- *"BaseModule: Keep only the VERSION variable, move the rest to `ExtraInformationModule`"*
- *"ExtraInformationModule — Terms are represented as document (name, hash, uri, last on-chain modification date)"*
- *"Add light deployment with only core modules"* / *"CMTATBaseCore for light deployment"*

Until v2.5.1, `terms` was a **core** attribute. In v3.0.0-rc.0 it was reclassified as an extension in the same
release that defined Light as "core only", so Light was created without it. No explicit decision to drop `terms`
from Light is recorded in `doc/`, `contracts/` NatSpec or the CHANGELOG. Searched with
`grep -rn -i "light" doc/ contracts/ … | grep -i "terms|extra|tokenId"`; the only results describe the absence and give no reason.

### 3.1 Why this matters

- **CMTA framework compliance.** `terms` is the only mandatory CMTAT attribute that Light lacks (`name` and
  `symbol` are provided by `TokenAttributeModule`). `tokenId` is optional, so its absence from Light is not a
  deviation. Light is recommended for stablecoins, yet no document flags the missing `terms`.
- **Regulatory use.** Even for a stablecoin, a pointer to legally required documentation (white paper, terms of
  issuance, e.g. MiCA) is the field most likely to be required on-chain. Today the only option is to switch to
  Standard (about twice the bytecode).

---

## 4. Plan: extract `TermsModule` with its own storage namespace

### 4.1 Goals and constraints

1. `terms` is available in **all** variants, including Light.
2. `ExtraInformationModule` **inherits** from `TermsModule`. Terms are stored in **one place only**: the
   `TermsModule` namespace. That namespace serves both Light and the full variants; `ExtraInformationModule` never
   writes terms itself.
3. The public ABI of the full variants does not change: `terms()`, `setTerms(DocumentInfo)`, `Terms` event,
   `EXTRA_INFORMATION_ROLE` gating, and `ERC7551Module.setTerms(bytes32,string)` with name preservation (NM-22).
4. Module numbering / dependency direction (CLAUDE.md rule): `TermsModule` is a **core** wrapper module, and
   extensions/options depend on it, never the other way round. This follows the existing chain
   `ERC7551Module (options) → ExtraInformationModule (extensions)`.
5. Storage-breaking changes are allowed. They are used where they bring a real benefit (the dedicated namespace) and
   avoided where they are only cosmetic (§4.2.5). Target release: **v3.4.0** (§4.2.2).

### 4.2 Storage strategy (the key decision)

| Option | Description | Upgrade impact | Verdict |
| --- | --- | --- | --- |
| A. Shared namespace, struct declared once in `TermsModule` | `TermsModule` declares the whole `ExtraInformationModuleStorage` struct (`_tokenId, _terms, _information`) at the existing slot `0xd2d5…d100`, and `ExtraInformationModule` reuses it | None (byte-identical layout) | Not needed: its only advantage was avoiding a storage break, which is now allowed |
| **B. Dedicated namespace `CMTAT.storage.TermsModule`, `_terms` at offset 0** | `TermsModule` owns its own struct `{ CMTATTerms _terms; }`. `ExtraInformationModule` keeps `_tokenId` / `_information` and a deprecated placeholder where `_terms` used to be | Proxies deployed before v3.4.0 must migrate terms with a one-time `reinitializer` (§4.2.4) | **Recommended** |
| C. Reorder `ExtraInformationModuleStorage` (`_terms` first) | Terms at offset 0 of the existing namespace | Corrupts every field of every deployed v3 proxy | Rejected |

#### 4.2.1 Why option B

- **It follows the codebase convention.** All 16 ERC-7201 namespaces in `contracts/modules` belong to exactly one
  module. Option A would be the first namespace shared by two modules, and `TermsModule` would declare `_tokenId` /
  `_information` fields that it never uses. Light would carry these unused fields too, under a misleading namespace
  name (`ExtraInformationModule`).
- **`_terms` is at offset 0** of its own namespace, which matches its status as the only mandatory attribute.
- **There is a precedent.** v3.3.0 moves `name`/`symbol` from `CMTAT.storage.ERC20BaseModule` to a new
  `CMTAT.storage.TokenAttributeModule` namespace for the same reason: a core module that owns its data independently
  of the ERC-20 layer. The CHANGELOG (*Security*) requires a one-time `reinitializer` for pre-3.3 proxies. v3.4.0
  applies the same pattern to terms.

#### 4.2.2 Release: v3.4.0

The change is scheduled for **v3.4.0**, after v3.3.0. Consequences:

- **v3.3.0 proxies** (and `v3.3.0-rc*` testnet proxies) need a terms-only migration when upgrading to v3.4.0.
- **Pre-3.3 proxies** upgrading directly to v3.4.0 need both migrations (`name`/`symbol` and terms). The reference
  implementation (§4.2.4) does both in one reinitializer.
- **Versioning policy.** The CHANGELOG semver section says an *"Incompatible proxy storage change"* requires a
  **MAJOR** bump. v3.3.0 already broke storage (`name`/`symbol`) in a minor release, so v3.4.0 follows existing
  practice, but the policy text and the practice disagree. When this ships, either amend the policy (e.g. "storage
  changes that come with a documented migration path may ship in a MINOR release") or add an explicit note in the
  v3.4.0 CHANGELOG entry. See decision §4.12.

#### 4.2.3 Layouts

New namespace (formula checked: it reproduces the existing `ExtraInformationModule` constant exactly):

```text
keccak256(abi.encode(uint256(keccak256("CMTAT.storage.TermsModule")) - 1)) & ~bytes32(uint256(0xff))
= 0x74e2e37bbafef443a4452da313c639f32718bb107c63161b05a5dc08086d6a00
```

| `TermsModule` slot | Field |
| --- | --- |
| `T + 0` | `_terms.name` |
| `T + 1` | `_terms.doc.uri` |
| `T + 2` | `_terms.doc.documentHash` |
| `T + 3` | `_terms.doc.lastModified` |

`ExtraInformationModule` (namespace unchanged, `0xd2d5…d100`):

| Slot | Before | After |
| --- | --- | --- |
| `E + 0` | `_tokenId` | `_tokenId` (unchanged) |
| `E + 1 .. E + 4` | `_terms` | `_legacyTerms`: **deprecated placeholder**, read only by the migration helper, never written except to be cleared |
| `E + 5` | `_information` | `_information` (unchanged) |

Rules:

- **Do not remove the `_terms` field from `ExtraInformationModuleStorage`.** It sits in the middle of the struct, so
  removing it would shift `_information` from `E+5` to `E+1`. (In `ERC20BaseModule`, `_name`/`_symbol` could be dropped
  only because they were the trailing fields.) Keep it with the same type (`CMTATTerms`), renamed `_legacyTerms`,
  with a `/// @custom:oz-renamed-from _terms` annotation so that the OpenZeppelin upgrades validation accepts the rename.
  §4.9 includes a test that checks this.
- Keep `ExtraInformationModule`'s namespace string and constant unchanged.
- `TermsModule` follows the usual module pattern: a `private` constant, its own struct and a `private` getter, like
  `TokenAttributeModule`.

#### 4.2.4 Migration of proxies deployed before v3.4.0

`ExtraInformationModule` gets an `internal` helper. The compiler leaves out internal functions that are never called,
so this adds **no bytecode** to the shipped variants. It is only compiled into an implementation whose reinitializer
calls it:

```solidity
/// @dev One-time migration for proxies deployed before v3.4.0 (terms moved to CMTAT.storage.TermsModule).
/// Copies the legacy terms as-is (name, uri, hash and the original lastModified), then clears the legacy slots.
/// Does nothing if the legacy slot is empty; does not overwrite terms already set in TermsModule.
function _migrateLegacyTerms() internal virtual;
```

- It copies the whole struct directly instead of calling `_setTerms`, because `_setTerms` would reset `lastModified`
  to the upgrade block and lose the real date of the last terms change.
- It emits no `Terms` event, because the value returned by `terms()` does not change.
- It needs an internal hook in `TermsModule` to write the stored struct without touching `lastModified`, e.g.
  `_restoreTerms(CMTATTerms memory)`. That hook is also left out of the bytecode when unused.

Ship a **reference upgrade implementation** in `contracts/mocks/upgrade/` (e.g. `CMTATUpgradeableStandardV34MigrationMock`)
with a `reinitializer(n)` function that:

- always migrates terms (`_migrateLegacyTerms()`);
- also migrates `name`/`symbol` when the source proxy predates v3.3.0 (the new `TokenAttributeModule` slot is empty
  and the old `ERC20BaseModule` slots are not).

The reinitializer version `n` must be higher than any version the proxy has already used. For example, a v3.3.0 proxy
that already ran a `reinitializer(2)` for `name`/`symbol` needs `reinitializer(3)`. Document this, because the
version cannot be fixed once for every proxy.

The mock also closes a gap: the repository documents the v3.3.0 `name`/`symbol` migration but has no code or test for
it. Integrators can copy this contract, and the tests use it.

An upgrade without the migration leaves `terms()` empty while `tokenId()` / `information()` stay intact. Document
this next to the existing `name`/`symbol` warning.

#### 4.2.5 Other storage breaks considered

Since breaking storage is allowed, each remaining compatibility measure was re-checked:

| Possible break | Effect on a proxy upgraded without (or with a wrong) migration | Benefit | Verdict |
| --- | --- | --- | --- |
| **Remove the `_legacyTerms` placeholder, keep the `ExtraInformationModule` namespace** | `_information` moves from `E+5` to `E+1`, which still holds the old `terms.name`. `information()` silently returns the old terms name: wrong but plausible-looking data, instead of an empty value | Cosmetic only. The placeholder costs no gas and no bytecode | **Rejected.** Silent wrong data is worse than an unused field |
| **Remove the placeholder and move `ExtraInformationModule` to a new namespace** | Fresh slots: `tokenId()` and `information()` read empty until migrated, so no garbage | A struct without the placeholder | **Rejected.** `tokenId`/`information` would need a migration too, only to delete one placeholder field. A fresh namespace is only worth it when a module's ownership changes, as it does for terms |
| **Drop the migration helper; document "call `setTerms` again after upgrade"** | `terms()` is empty until the operator calls `setTerms` | Less code, though `_migrateLegacyTerms` is already zero bytecode when unused | **Possible alternative.** It loses the original `lastModified` (reset to the upgrade block) and emits a misleading `Terms` event. Kept as the fallback if maintainers want no migration code at all (decision §4.12) |
| Change the `CMTATTerms` / `Document` field layout (e.g. pack `lastModified` with `documentHash`) | n/a, it lives in the new namespace | None: `bytes32` already fills a slot, and the strings cannot be packed | Rejected, no gain |
| Move `tokenId` to `TermsModule` as well | — | — | Out of scope: `tokenId` is optional (§4.8) |

**Net result:** the only storage break is relocating terms to `CMTAT.storage.TermsModule`. That one brings a
structural benefit: a single owner per namespace, terms at offset 0, and a clean Light layout.

### 4.3 Interface split

`contracts/interfaces/tokenization/ICMTAT.sol`:

- New `interface ICMTATTerms` with `struct CMTATTerms`, `event Terms(CMTATTerms)`, `terms()`, `setTerms(IERC1643CMTAT.DocumentInfo)`.
- `interface ICMTATBase is ICMTATTerms`, which keeps `TokenId` / `Information` events and the `tokenId` /
  `information` getters and setters. Existing code that refers to `ICMTATBase.CMTATTerms` still compiles, because
  the struct is inherited.
- ABI impact: function selectors and event topics **do not change** (`Terms((string,(string,bytes32,uint256)))`).
  The ABI `internalType` changes from `struct ICMTATBase.CMTATTerms` to `struct ICMTATTerms.CMTATTerms`, which can
  rename generated types (typechain, ethers codegen). Mention this in the CHANGELOG.

### 4.4 New `TermsModule`

`contracts/modules/wrapper/core/TermsModule.sol`, modelled on `TokenAttributeModule` (a core module with its own
ERC-7201 storage and an authorization hook):

```solidity
abstract contract TermsModule is Initializable, ICMTATTerms {
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.TermsModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TermsModuleStorageLocation = 0x74e2e37bbafef443a4452da313c639f32718bb107c63161b05a5dc08086d6a00;

    struct TermsModuleStorage {
        CMTATTerms _terms;
    }

    modifier onlyTermsManager() { _authorizeTermsManagement(); _; }

    function __TermsModule_init_unchained(IERC1643CMTAT.DocumentInfo memory terms_) internal virtual onlyInitializing;

    function setTerms(IERC1643CMTAT.DocumentInfo calldata) public virtual override(ICMTATTerms) onlyTermsManager;
    function terms() public view virtual override(ICMTATTerms) returns (CMTATTerms memory);

    function _setTerms(IERC1643CMTAT.DocumentInfo memory) internal virtual;   // moved from ExtraInformationModule
    function _setTermsDocument(bytes32, string memory) internal virtual;     // moved (NM-22)
    function _restoreTerms(CMTATTerms memory) internal virtual;              // migration only, keeps lastModified

    function _authorizeTermsManagement() internal virtual;
    function _getTermsModuleStorage() private pure returns (TermsModuleStorage storage $);
}
```

The `_setTerms($, …)` overload that takes a storage pointer is no longer needed outside the module. Keep only the
`memory` version for callers, plus a private storage-pointer variant if wanted for internal use.

### 4.5 Changes to `ExtraInformationModule`

- `abstract contract ExtraInformationModule is TermsModule, ICMTATBase`. `Initializable` comes through `TermsModule`.
- Storage: rename `_terms` to `_legacyTerms` (§4.2.3). Keep the namespace and the field order.
- Remove: `setTerms`, `terms`, both `_setTerms`, and `_setTermsDocument`. They are now inherited from `TermsModule`.
- Add `_migrateLegacyTerms()` (§4.2.4).
- Keep `__ExtraInformationModule_init_unchained(tokenId_, terms_, information_)` **with the same signature**, so its
  callers (`CMTATBaseGeneric`, `CMTATBaseAccessControl`) do not change. Internally it calls `_setTerms(terms_)`, which
  writes to the `TermsModule` namespace. The alternative is to have the base contracts call
  `__TermsModule_init_unchained` directly, but that adds churn without benefit.
- Bridge the authorization so that the full variants keep `EXTRA_INFORMATION_ROLE` without edits:

  ```solidity
  function _authorizeTermsManagement() internal virtual override(TermsModule) {
      _authorizeExtraInfoManagement();
  }
  ```

  The existing `_authorizeExtraInfoManagement` overrides in `CMTATBaseGeneric`, `CMTATBaseAccessControl` and
  `CMTATBaseERC7551` stay as they are.
- Override resolution to check when compiling: `ICMTATBase` no longer redeclares `terms`/`setTerms`, so the only
  implementation is in `TermsModule` and no `override(A, B)` list is needed. If the compiler disagrees, add
  `override(TermsModule, ICMTATTerms)` on a forwarding function.

### 4.6 `ERC7551Module`

No logic change. `_setTermsDocument` and `terms()` are now inherited through `ExtraInformationModule → TermsModule`.
Re-run the NM-22 name-preservation test.

### 4.7 Light (`CMTATBaseCore` + deployments)

- Add `TermsModule` to the `CMTATBaseCore` inheritance list.
- Add `_authorizeTermsManagement() internal virtual override(TermsModule) onlyRole(<role>) {}`.
- Initialization. **Decision needed**:
  - **(Recommended)** Extend `initialize` / `__CMTAT_init` / `__CMTAT_modules_init_unchained` and the
    `CMTATStandaloneLight` constructor with `IERC1643CMTAT.DocumentInfo memory terms_`, so terms can be set at deploy
    time like in every other variant. This is a **breaking change**: the Light constructor/`initialize` ABI and
    selector change, and deploy scripts plus `test/deploymentUtils.js` (`deployCMTATLightStandalone`,
    `deployCMTATLightProxy`) must be updated.
  - Alternative: keep the signature and set terms after deployment with `setTerms`. This is non-breaking, but the
    token is briefly live without terms.
- Role. **Decision needed**:
  - **(Recommended)** `DEFAULT_ADMIN_ROLE`. This matches Light's existing choice for `TokenAttributeModule`
    (`_authorizeTokenAttributeManagement` → admin) and adds no new role to Light's small role set.
  - `EXTRA_INFORMATION_ROLE`. The same role works across variants, but the constant would need to move to
    `TermsModule` or be redeclared, and its name is misleading in a module that has no "extra information".
  - New `TERMS_ROLE`. Clearest name, but it diverges from the full variants (which would keep
    `EXTRA_INFORMATION_ROLE`) and adds a new role hash to document.
- `supportsInterface`: not affected. `ICMTATBase` is not advertised through ERC-165 in any variant, so no change is needed.
- Upgrading existing Light proxies: no terms to migrate (Light never stored any), but the `name`/`symbol` migration
  still applies. The new `TermsModule` slot starts empty. `initialize` cannot run again, so after the upgrade the
  operator calls `setTerms` (document this in the upgrade notes).
- **Bytecode size**: measure before and after with the project's size tooling (Light is currently about half of
  Standard, so EIP-170 is not a concern). Record the delta in `doc/technical/stablecoin.md`. Note: the artifacts in
  `artifacts/` are currently the coverage-instrumented build and must not be used for this measurement.

### 4.8 `tokenId` stays in `ExtraInformationModule`

`tokenId` is **not** a mandatory CMTAT framework functionality (now stated in
`doc/technical/cmtat-specification-analyse.md`). It stays an optional attribute in `ExtraInformationModule` and is
not added to Light. Its slot (`E+0`) does not change.

### 4.9 Tests

- Split `test/common/ExtraInfoModuleCommon.js`: move the terms cases to a new `test/common/TermsModuleCommon.js`,
  and keep tokenId/information in `ExtraInfoModuleCommon.js`. Wire `TermsModuleCommon` into every suite that uses
  `ExtraInfoModuleCommon`, **and** into `test/deployment/light/deploymentStandaloneLight.test.js` and
  `deploymentUpgradeableLight.test.js`.
- Light-specific tests: role gating with the role chosen in §4.7, initial terms from the constructor/`initialize`,
  `lastModified` set, `Terms` event.
- **Storage relocation and migration tests** (the key guarantee), using the reference migration mock (§4.2.4):
  1. Deploy a **v3.3.0** `CMTATUpgradeableStandard` (and an ERC-7551) proxy, set tokenId/terms/information, then
     upgrade to v3.4.0 with the migration `reinitializer`. Assert that `terms()` is identical **including the
     original `lastModified`**, `termsHash()` is unchanged, `tokenId()` / `information()` / `name()` / `symbol()`
     are unchanged, and the legacy slots `E+1..E+4` are zero.
  1b. Same from a **v3.2.0** proxy: the same reinitializer also restores `name()` / `symbol()`.
  2. Upgrade **without** the migration: `terms()` is empty, while `tokenId()` / `information()` are intact. This
     documents the failure mode.
  3. Migration edge cases: running it a second time reverts (reinitializer version); an empty legacy slot leaves
     `terms()` empty; terms already set in `TermsModule` are not overwritten.
  4. Raw `getStorageAt`: terms at `0x74e2…6a00 + 0..3`, `_information` still at `E+5`.
  5. OpenZeppelin `validateUpgrade` v3.3.0 → v3.4.0 (and v3.2.0 → v3.4.0) passes, which checks the `oz-renamed-from` annotation.
  6. Upgrade a v3.3.0 Light proxy: `terms()` is empty, then `setTerms` works with the Light role.
- Re-run `ERC7551ModuleCommon.js` (`testERC7551SetTermsPreservesDocumentName`).
- Update **`doc/test/Test.md`**: add a new `Terms` row in the feature matrix (✓ for Light too), narrow the
  `ExtraInformation` row to tokenId/information, add an entry for `TermsModuleCommon.js` with its `it` count, and
  change the Light note at l.86.

### 4.10 Documentation and repo hygiene

| File | Change |
| --- | --- |
| `doc/modules/core/terms.md` (new) | Module reference page: API, events, role, namespace `CMTAT.storage.TermsModule` |
| `doc/modules/extensions/ExtraInformation/extraInformation.md` | Explain that terms now come from `TermsModule` (inherited), the deprecated `_legacyTerms` placeholder, and `_migrateLegacyTerms` |
| `doc/technical/stablecoin.md` (l.15, 56, 97) | Light now has `terms`. Update the "intentionally absent" table and the constructor description |
| `doc/README.md` | Light row (l.191, 2637), role table (l.~1269, Light section), module list (l.856), CMTAT framework table (note Light coverage), inheritance schemas |
| `doc/technical/cmtat-specification-analyse.md` | `tokenId` marked optional (**done**). After implementation: per-variant coverage of `terms` (Light ✔) |
| `doc/technical/deployment.md` | Add `CMTAT.storage.TermsModule` to the ERC-7201 slot table |
| `doc/technical/upgradeable.md` | New "Upgrading to v3.4.0" section: terms migration (plus `name`/`symbol` for pre-3.3 sources), reinitializer version choice, reference mock, failure mode if skipped |
| `doc/technical/access-control.md` | Light role for `setTerms` |
| `doc/SUMMARY.md` | Module list (`TermsModule` under core) |
| `doc/schema/**` (surya, plantuml) | Regenerate for `TermsModule`, `ExtraInformationModule`, `CMTATBaseCore` |
| `.claude/tree/contracts_tree.txt`, `.claude/tree/test_tree.txt` | Add `TermsModule.sol`, the migration mock, `TermsModuleCommon.js` and the migration test (CLAUDE.md rule) |
| `CHANGELOG.md` | New module; *Storage layout* entry (terms moved to `CMTAT.storage.TermsModule`, `_terms` → `_legacyTerms`); new v3.4.0 *Security* entry for the terms migration (pointing to the v3.3.0 `name`/`symbol` entry for older proxies); versioning-policy note (§4.2.2); Light breaking change (initializer/constructor); ABI `internalType` rename |
| `VersionModule` | `VERSION = "3.4.0"` |

### 4.11 Implementation order

1. Interface split (`ICMTATTerms`, `ICMTATBase is ICMTATTerms`). Compile.
2. Add `TermsModule` (new namespace), move the code out of `ExtraInformationModule`, rename `_terms` → `_legacyTerms`,
   add `_migrateLegacyTerms` / `_restoreTerms`. Compile. Run the full suite with no behaviour change expected on fresh
   deployments (Light still untouched).
3. Add the reference migration mock and the relocation tests (§4.9 items 1–5) **before** touching Light.
4. Add `TermsModule` to `CMTATBaseCore` and the Light deployments and fixtures, with the role and initializer chosen in §4.7.
5. Light tests, then `Test.md`.
6. Measure size, update docs and schemas, then the CHANGELOG.
7. `npm run test`, `npm run coverage`.

### 4.12 Decisions needed from maintainers

1. Versioning policy: amend the CHANGELOG semver rule, or add an explicit v3.4.0 exception note, since this storage
   break ships in a minor release (§4.2.2).
2. Migration support: keep the zero-bytecode `_migrateLegacyTerms` helper plus the reference mock (recommended), or
   only document "re-set terms with `setTerms` after upgrading", which loses the original `lastModified` (§4.2.5).
3. Light initializer: add `terms_` (breaking, recommended) or set it after deployment only.
4. Light role for `setTerms`: `DEFAULT_ADMIN_ROLE` (recommended), `EXTRA_INFORMATION_ROLE`, or a new `TERMS_ROLE`.
5. Accept the ABI `internalType` rename (`ICMTATBase.CMTATTerms` → `ICMTATTerms.CMTATTerms`), or keep the struct in
   `ICMTATBase` and have `TermsModule` implement a reduced interface that imports it. The second option avoids the
   rename but makes the interfaces less tidy.
