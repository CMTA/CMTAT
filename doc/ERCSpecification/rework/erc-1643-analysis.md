# ERC-1643 (rework) — Conformance Analysis of the CMTAT Implementation and Mocks

**Spec analysed:** [`erc-1643.md`](./erc-1643.md) (rework — adds the `ERC1643InvalidName` /
`ERC1643MissingDocument` custom errors, ERC-165 detection guidance, and precise function
requirements).

**Files reviewed**

| Role | File |
|------|------|
| Interface | `contracts/interfaces/tokenization/draft-IERC1643.sol` |
| In-contract module (primary) | `contracts/modules/wrapper/extensions/DocumentERC1643Module.sol` (via `1_CMTATBaseDocument.sol`) |
| ERC-165 registration | `contracts/modules/2_CMTATBaseAccessControl.sol` (`:56`) |
| Engine-delegating module (option) | `contracts/modules/wrapper/options/DocumentEngineModule.sol` |
| Engine interface | `contracts/interfaces/engine/IDocumentEngine.sol` |
| **Mocks** | `contracts/mocks/DocumentEngineMock.sol`, `contracts/mocks/engine/CMTATDocumentEngineModuleMock.sol` |

CMTAT ships **two** document-management strategies:
- **In-contract** (`DocumentERC1643Module`): stores documents in the token's own ERC-7201 storage. Used by the main deployment variants (reached through `2_CMTATBaseAccessControl → CMTATBaseDocument`).
- **Engine-delegating** (`DocumentEngineModule`): forwards every call to an external `IDocumentEngine` contract. Exercised by `CMTATDocumentEngineModuleMock` + `DocumentEngineMock`.

---

## 1. Verdict

- **In-contract `DocumentERC1643Module` — CONFORMANT.** All function MUSTs, both events, the
  two custom errors, the timestamp rule, and O(1) swap-pop enumeration are correct. ERC-165 id
  `0xecfecec8` is advertised.
- **Engine-delegating `DocumentEngineModule` — CONFORMANT as a pass-through**, but its
  observable ERC-1643 behaviour (events, error shapes, enumeration correctness) is entirely
  inherited from whatever engine is attached. With the shipped `DocumentEngineMock` it is **not**
  fully conformant (see §5).
- **`DocumentEngineMock` — NON-CONFORMANT** on two counts (a removal bug that corrupts
  enumeration, and non-standard event signatures) plus three minor SHOULD misses. It is a
  test-only contract, but it is the reference engine used to exercise the delegating path, so the
  defects matter for what the tests actually prove.

---

## 2. Interface and ERC-165 id — CONFORMANT (verified)

`draft-IERC1643.sol` declares exactly the spec's four functions, both events, and both errors.
`getDocument` returns the **flat** `(string uri, bytes32 documentHash, uint256 lastModified)`
tuple required by the spec `:58` (the internal `struct Document` is storage-only and does not
affect the ABI).

Recomputed selectors and id:

| Selector | Value |
|----------|-------|
| `getDocument(bytes32)` | `0xb10d6b41` |
| `getAllDocuments()` | `0x9fa5f50b` |
| `setDocument(bytes32,string,bytes32)` | `0x010648ca` |
| `removeDocument(bytes32)` | `0xc3501848` |
| **`type(IERC1643).interfaceId`** (XOR) | **`0xecfecec8`** ✓ |

`2_CMTATBaseAccessControl.supportsInterface` (`:56`) returns `true` for
`type(IERC1643).interfaceId` (and ERC-165 via `AccessControlUpgradeable`), satisfying the spec's
ERC-165 SHOULD `:83`. Here `type(IERC1643).interfaceId` is safe because `IERC1643` does not
inherit another interface, so it covers exactly the four selectors.

---

## 3. In-contract `DocumentERC1643Module` — CONFORMANT

| Spec requirement | Implementation | OK |
|------------------|----------------|----|
| `getDocument` returns latest values | `:28-31` reads the mapping | ✅ |
| `getDocument` returns empty for missing, MUST NOT revert | default struct → `("", 0x0, 0)` | ✅ |
| `setDocument` creates / overwrites | `:40-43` writes fields | ✅ |
| `setDocument` updates last-modified | `:43` `= block.timestamp` | ✅ |
| `setDocument` emits `DocumentUpdated` after state change | `:50` (standard signature) | ✅ |
| `setDocument` SHOULD revert on `name == 0` with `ERC1643InvalidName` | `:38` `require(name != 0, ERC1643InvalidName())` | ✅ |
| `removeDocument` removes the entry | `:53-70` swap-pop + `delete` | ✅ |
| `removeDocument` emits `DocumentRemoved` with removed metadata | `:72` reads `document` **before** delete (`:58`) | ✅ |
| `removeDocument` SHOULD use `ERC1643MissingDocument` when absent | `:56` `require(key != 0, ERC1643MissingDocument())` | ✅ |
| `getAllDocuments` includes added, excludes removed | `_documentNames` maintained on both paths | ✅ |
| Authorization on mutators | `onlyDocumentManager` → `DOCUMENT_ROLE` | ✅ (spec Security Considerations) |

The removal (`:59-68`) correctly performs the swap-pop **and updates the moved name's index**:
`$._documentKey[movedName] = key;` (`:65`). This is the detail the mock gets wrong (§5.1).

**No conformance gaps found in the in-contract module.**

---

## 4. Engine-delegating `DocumentEngineModule` — CONFORMANT pass-through, with caveats

- `getDocument` / `getAllDocuments` return empty values when no engine is set
  (`DocumentEngineModule.sol:64-81`) — matches the "empty, do not revert" rule. ✅
- `setDocument` / `removeDocument` forward to the engine (`:83-91`) under `onlyDocumentManager`.
  They perform **no** local `name == 0` or existence checks — correctness (zero-name rejection,
  `ERC1643MissingDocument`, event emission, enumeration) is entirely the engine's responsibility.
  A conformant engine ⇒ conformant token; the shipped mock engine is not conformant (§5), so the
  delegating token inherits those defects.
- **ERC-165 gap in the mock wiring.** `CMTATDocumentEngineModuleMock` extends `CMTATBaseCore`
  (whose `supportsInterface`, `0_CMTATBaseCore.sol:173`, does **not** register `0xecfecec8`) and
  does not override it. So a token using the engine variant this way exposes all four ERC-1643
  functions but returns `false` for `type(IERC1643).interfaceId` — a SHOULD miss (`:83`) and an
  inconsistency with the in-contract variant, which advertises it. Recommendation: have the
  engine-variant base register `type(IERC1643).interfaceId` too.
  **UPDATE — fixed:** `CMTATDocumentEngineModuleMock` now overrides `supportsInterface` to return
  `true` for `type(IERC1643).interfaceId` (`0xecfecec8`), with a test (`testAdvertisesERC1643Interface`).

### 4.1 [Event/subscription compliance of the delegating token] — FIXED

ERC-1643 is a **per-contract** interface: `setDocument` MUST emit `DocumentUpdated` (`:96`),
`removeDocument` MUST emit `DocumentRemoved` (`:106`), and implementations MUST support
*subscribing to updates* (`:35`). The event carries **no address field**, so a subscriber is
expected to watch *the contract that exposes `setDocument`* — here, the token.

Originally the delegating token's `setDocument`/`removeDocument` only forwarded to the engine and
emitted **nothing on the token's own address**. A `DocumentUpdated` log *was* produced in the
transaction, but at the **engine's** address (the `LOG` opcode runs in the engine's frame), so a
standard ERC-1643 subscriber watching the *token* saw nothing — and the addressless event could
not be attributed back to the token if the engine is shared across tokens. Since the token
advertises `type(IERC1643).interfaceId`, it *claims* the interface while only honoring its read
half (`getDocument`/`getAllDocuments` delegate), so this was a genuine conformance gap, not merely
an architectural quirk.

**UPDATE — fixed (dual emission).** `DocumentEngineModule.setDocument`/`removeDocument`
(`options/DocumentEngineModule.sol`) now re-emit the standard `DocumentUpdated`/`DocumentRemoved`
event on the **token's own address** after forwarding to the engine, so token-address subscribers
observe updates as the standard assumes. `removeDocument` reads `getDocument(name)` before
forwarding to include the removed metadata (`:106`). Both mutators now also revert with
`CMTAT_DocumentEngineModule_NoDocumentEngine` when no engine is set (spec `:97` "MUST revert if the
update cannot be persisted"), which also prevents a false emit. Because the token now emits its own
attributable event, a non-standard `DocumentUpdatedForContract`-style event is unnecessary.
Regression tests: `testTokenReEmitsStandardDocumentEvents`, `testCannotSetDocumentWithoutEngine`.
(The engine also emits on its own address; under the per-contract model the two log streams are
independent and both conformant.)

---

## 5. `DocumentEngineMock` — findings

> **UPDATE — fixed.** `DocumentEngineMock` has been rewritten to **reuse the production
> `DocumentERC1643Module`** (`contract DocumentEngineMock is DocumentERC1643Module` with a no-op
> `_authorizeDocumentManagement`). This eliminates §5.1 and §5.2 at once — the mock now inherits
> the correct swap-pop-with-key-update enumeration and the standard flat
> `DocumentUpdated`/`DocumentRemoved` events, and also gains the `name == 0` rejection
> (`ERC1643InvalidName`) and `ERC1643MissingDocument` error (resolving §5.3's first two points).
> Two regression tests were added in `test/standard/modules/DocumentModule/DocumentModule.test.js`
> (remove-a-moved-document, and standard-event emission). The findings below are retained for the
> record.

`DocumentEngineMock` (originally `contracts/mocks/DocumentEngineMock.sol`) implemented
`IERC1643Whole` (`IDocumentEngine` + a struct-based `setDocument(DocumentInfo)`). As a test-only
contract it is not production code, but it is the reference engine behind the delegating path.

### 5.1 [Bug — enumeration corruption on removal] Severity: High (for a mock)

`removeDocument` (`:87-97`) swap-pops the names array but **never updates the moved entry's
`documentKey`**:

```solidity
documentNames[documentKey[name] - 1] = documentNames[documentNames.length - 1];
documentNames.pop();
delete documents[name];
documentKey[name] = 0;
// missing: documentKey[movedName] = documentKey[name];
```

After removing a **non-last** document, the element moved into its slot keeps its *old* index in
`documentKey`. Consequences:
- a subsequent `removeDocument(movedName)` uses the stale index and writes/read at
  `documentNames[oldLen-1]`, which is now **out of bounds** → panic revert, so an existing
  document **cannot be removed** (violates `removeDocument` MUST, spec `:105`), and
- `getAllDocuments` continues to list a name whose key is desynchronised — breaking the
  "enumeration consistency after multiple add/update/remove operations" test case (`:135`).

Reproduction: `setDocument(A); setDocument(B); setDocument(C); removeDocument(A); removeDocument(C)` → the second removal reverts even though `C` exists.

**Fix:** mirror the production module (`DocumentERC1643Module.sol:59-68`) — update
`documentKey[movedName]` after the swap:

```solidity
uint256 key = documentKey[name];
uint256 index = key - 1;
uint256 lastIndex = documentNames.length - 1;
if (index != lastIndex) {
    bytes32 movedName = documentNames[lastIndex];
    documentNames[index] = movedName;
    documentKey[movedName] = key;   // <-- the missing line
}
documentNames.pop();
delete documents[name];
delete documentKey[name];
```

### 5.2 [Non-standard event signatures] Severity: Medium (for a mock)

`IERC1643Whole` **redefines** the events with a `Document` struct parameter
(`:23-24`): `event DocumentUpdated(bytes32 indexed name, Document doc)` /
`DocumentRemoved(bytes32 indexed name, Document doc)`. The mock's setters/remover emit *these*
(`:63,82,96`), whose `topic0` is `DocumentUpdated(bytes32,(string,bytes32,uint256))` — **different
from** the ERC-1643-mandated `DocumentUpdated(bytes32,string,bytes32)` (`:72`). An integrator
subscribed to the standard event signature will therefore **not** observe document changes made
through this engine, even though the spec makes emitting `DocumentUpdated`/`DocumentRemoved` a
MUST (`:96,106`). Because the delegating token forwards to the engine, the token also emits only
the non-standard event.

**Fix:** emit the standard flat-parameter events
(`emit DocumentUpdated(name, uri, documentHash);`) and drop the struct-based overloads, so the
engine's observable event stream matches the interface it claims.

### 5.3 [SHOULD misses] Severity: Low / informational

- **No `name == bytes32(0)` rejection** in either `setDocument` overload — the spec SHOULD revert
  with `ERC1643InvalidName` (`:98,101`). The production module enforces this; the mock does not.
- **Non-recommended removal error:** `removeDocument` reverts with a locally-declared
  `DocumentDoesNotExist()` (`:36,89`) rather than the interface's `ERC1643MissingDocument()`. The
  spec *permits* a different error (`:109` "MAY use different error names"), so this is allowed but
  does not follow the SHOULD (`:108`) and diverges from the production module.
- **No ERC-165 `supportsInterface`** on the engine — spec SHOULD (`:81-83`). Minor for a
  standalone engine, but it means a token cannot discover the engine's ERC-1643 support on-chain.

---

## 6. Suggestions

1. **Fix `DocumentEngineMock.removeDocument`** (§5.1) — the missing `documentKey` update. This is
   a genuine correctness bug, not just a style issue, and it can make document-engine tests pass
   for the wrong reasons or hide regressions in the delegating path.
2. **Emit standard ERC-1643 events from `DocumentEngineMock`** (§5.2) so the engine variant's
   observable behaviour matches the interface. Add a test asserting the token emits
   `DocumentUpdated(bytes32,string,bytes32)` (not the struct form) through the engine.
3. **Advertise `type(IERC1643).interfaceId` on the engine variant** (§4) — have the
   engine-variant base (or `CMTATDocumentEngineModuleMock`) override `supportsInterface` to
   include `0xecfecec8`, matching the in-contract variant and the spec SHOULD.
4. **Align the mock's zero-name and error behaviour** with the production module (§5.3): reject
   `name == 0` with `ERC1643InvalidName`, and prefer `ERC1643MissingDocument` on removal, so the
   mock models the standard faithfully.
5. **Add the enumeration-consistency test** from the spec Test Cases (`:135`) against **both**
   the in-contract module and the engine mock: add A/B/C, remove the first, then remove the moved
   element, and assert `getAllDocuments` stays consistent and no removal reverts. This test would
   currently pass for the in-contract module and fail for the mock — surfacing §5.1.

---

## 7. Summary tables

### In-contract `DocumentERC1643Module` (production path)
| Requirement | Status |
|-------------|--------|
| `getDocument` flat return, empty-for-missing, no revert | ✅ |
| `setDocument` create/overwrite, timestamp, event, zero-name revert | ✅ |
| `removeDocument` remove, event w/ metadata, missing-doc error | ✅ |
| `getAllDocuments` enumeration correctness (swap-pop + key update) | ✅ |
| Custom errors `ERC1643InvalidName` / `ERC1643MissingDocument` | ✅ |
| Authorization on mutators (`DOCUMENT_ROLE`) | ✅ |
| ERC-165 `0xecfecec8` advertised | ✅ (verified) |

### Engine variant + `DocumentEngineMock` (after the fix)
| Requirement | Status |
|-------------|--------|
| `DocumentEngineModule` pass-through, empty-when-unset, no revert | ✅ |
| Delegating token emits standard events on its **own** address (per-contract subscription) | ✅ **fixed** — dual emission (§4.1) |
| Engine `removeDocument` enumeration consistency | ✅ **fixed** — reuses `DocumentERC1643Module` (§5.1) |
| Engine emits standard `DocumentUpdated`/`DocumentRemoved` | ✅ **fixed** — flat events via module reuse (§5.2) |
| Engine zero-name rejection (SHOULD) | ✅ **fixed** — inherits `ERC1643InvalidName` |
| Engine uses `ERC1643MissingDocument` (SHOULD; MAY differ) | ✅ **fixed** — inherits `ERC1643MissingDocument` |
| Engine-variant `supportsInterface` advertises `0xecfecec8` (SHOULD) | ✅ **fixed** — `CMTATDocumentEngineModuleMock.supportsInterface` override (§4) |
