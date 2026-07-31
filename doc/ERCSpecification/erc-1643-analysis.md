# ERC-1643 Conformance Analysis — CMTAT

**Scope of review:** does CMTAT correctly implement ERC-1643 (Document Management)?
**Checked against both specs in this repo:**
- Rework: [`rework/erc-1643.md`](./rework/erc-1643.md) — *"Document Management for Security Tokens"* (ethereum/ERCs PR #1754, draft).
- Original: [`original/draft-erc-1643-document.md`](./original/draft-erc-1643-document.md) — the 2018 ERC-1400 draft (GitHub issue only, never merged).

**CMTAT sources reviewed:**
- Interface: `contracts/interfaces/tokenization/draft-IERC1643.sol`
- Native (in-contract) module: `contracts/modules/wrapper/extensions/DocumentERC1643Module.sol` (via `CMTATBaseDocument`, level 1)
- ERC-165 registration + role gate: `contracts/modules/2_CMTATBaseAccessControl.sol`
- External-engine alternative: `contracts/modules/wrapper/options/DocumentEngineModule.sol` (forwards to any `IERC1643` engine)

**Reviewed on:** CMTAT v3.3.0-rc2/rc3 (`dev`).

---

## Verdict

**CMTAT correctly and fully implements ERC-1643** — every `MUST` in the rework spec and every requirement of the original draft is satisfied by the on-chain behaviour, and the `SHOULD`s (ERC-165 detection, `bytes32(0)` rejection with the named error, `lastModified != 0` absence sentinel) are met too. Both the rework and the original are ABI-compatible with CMTAT's interface.

The only shortfalls are **non-normative**: three of the spec's *recommended test cases* are not asserted in the suite (the code implements them correctly), one advisory security-consideration (pagination) is not addressed, and one NatSpec `@return` line is mislabeled. None affect conformance.

---

## Rework spec — clause-by-clause (`rework/erc-1643.md`)

### Interface shape (§Specification / §Interface)

| Spec member | CMTAT | OK |
|---|---|---|
| `event DocumentUpdated(bytes32 indexed name, string uri, bytes32 documentHash)` | identical selector (`draft-IERC1643.sol:47`) | ✅ |
| `event DocumentRemoved(bytes32 indexed name, string uri, bytes32 documentHash)` | identical (`:49`) | ✅ |
| `error ERC1643InvalidName()` | defined (`:14`) | ✅ |
| `error ERC1643MissingDocument()` | defined (`:12`) | ✅ |
| `setDocument(bytes32,string,bytes32)` | present (`:43`) | ✅ |
| `removeDocument(bytes32)` | present (`:45`) | ✅ |
| `getDocument(bytes32) → (string,bytes32,uint256)` | present (`:36`) | ✅ |
| `getAllDocuments() → bytes32[]` | present (`:41`) | ✅ |

The document entry stores exactly the spec's three fields — URI (`string`), content hash (`bytes32`), last-modified (`uint256`) — via the `Document` struct (`:17`). CMTAT exposes them as the flat `(uri, documentHash, lastModified)` tuple the ABI requires, so representing them internally as a struct is invisible to callers. ✅

### `getDocument` (§Function Requirements)

| Requirement | CMTAT (`DocumentERC1643Module.sol:28`) | OK |
|---|---|---|
| MUST return the latest values | reads `$._documents[name]` | ✅ |
| MUST return empty values when absent (`""`, `bytes32(0)`, `0`) | mapping default is exactly that | ✅ |
| MUST NOT revert solely because absent | plain storage read, no guard | ✅ |
| SHOULD keep stored `lastModified != 0` as the absence sentinel | `setDocument` writes `block.timestamp` (always > 0 on-chain); absent = 0 | ✅ |

### `setDocument` (§Function Requirements)

| Requirement | CMTAT (`:37`) | OK |
|---|---|---|
| MUST create when absent / overwrite when present | writes struct unconditionally; pushes the name only when `_documentKey[name] == 0` | ✅ |
| MUST update the last-modified timestamp | `document.lastModified = block.timestamp` | ✅ |
| MUST emit `DocumentUpdated` after state changes | emitted last | ✅ |
| MUST revert if it cannot persist | writes to storage; a failed write reverts | ✅ |
| SHOULD revert on `name == bytes32(0)` with `ERC1643InvalidName()` | `require(name != bytes32(0), ERC1643InvalidName())` | ✅ |
| `uri` / `documentHash` MAY be empty | not rejected | ✅ |

### `removeDocument` (§Function Requirements)

| Requirement | CMTAT (`:53`) | OK |
|---|---|---|
| MUST remove the named entry | `delete $._documents[name]` + key cleanup | ✅ |
| MUST emit `DocumentRemoved` with the removed metadata | reads `document` into memory **before** delete, emits `(name, uri, documentHash)` | ✅ |
| MUST revert if removal cannot complete | `require(key != 0, ERC1643MissingDocument())` | ✅ |
| SHOULD use `ERC1643MissingDocument()` when absent | exactly that | ✅ |

### `getAllDocuments` (§Function Requirements)

| Requirement | CMTAT (`:33`) | OK |
|---|---|---|
| MUST include every set-and-not-removed name | returns `_documentNames` | ✅ |
| MUST NOT include removed names | swap-and-pop removal keeps the array exact | ✅ |
| Order unspecified; removal MAY reorder | swap-and-pop moves the last element into the freed slot — matches the "consumers MUST NOT rely on ordering" note | ✅ |

The removal uses 1-based `_documentKey` indexing (`0` = absent) plus swap-and-pop for O(1) deletes — precisely the "index tracking to support O(1) removals" pattern the spec's Reference Implementation describes (§Reference Implementation). ✅

### Interface Detection — ERC-165 (§Interface Detection, SHOULD)

`type(IERC1643).interfaceId` (`0xecfecec8`) is returned by `supportsInterface` in `2_CMTATBaseAccessControl.sol:57`, which every document-bearing deployment inherits (the native module sits at level 1, the registration at level 2). ✅ The external-engine mock advertises it too (`CMTATDocumentEngineModuleMock.sol:38`).

### Authorization (§Security Considerations)

`setDocument` / `removeDocument` are gated by `onlyDocumentManager` → `_authorizeDocumentManagement()` → `onlyRole(DOCUMENT_ROLE)` (`2_CMTATBaseAccessControl.sol:88`; Light path `0_CMTATBaseGeneric.sol:86`). Reads are unrestricted. This matches the spec's "protect `setDocument`/`removeDocument` with appropriate authorization". ✅

---

## Original draft (`original/draft-erc-1643-document.md`)

The original is a strict subset of the rework: same four functions, same two events, no custom errors, no ERC-165. CMTAT is a superset and remains **ABI-compatible**:

- `getDocument`/`setDocument`/`removeDocument`/`getAllDocuments` selectors are identical (the original's `_name`/`_uri`/`_documentHash` parameter names don't affect the ABI signature). ✅
- The original's events `DocumentUpdated(bytes32 indexed,string,bytes32)` / `DocumentRemoved(...)` have the same topic-0 as CMTAT's. ✅
- Original: *"`setDocument`/`removeDocument` MUST throw if not stored/removed."* CMTAT reverts (with named custom errors instead of the original's implicit throw) — the rework explicitly permits custom error names/signatures, and the original only requires *a* revert. ✅
- CMTAT adds `name == bytes32(0)` rejection, which the original does not mention. This is a stricter (safe) addition, not a violation. ✅

The interface header even documents the sole intentional deviation: *"Contrary to the original specification, use a struct Document to represent a Document"* (`draft-IERC1643.sol:8`) — an internal representation choice, ABI-transparent.

---

## Non-normative gaps (no conformance impact)

1. **Test coverage vs the spec's recommended Test Cases.** ~~The suite was missing event-emission, `name==0`, and missing-doc assertions.~~ **Fixed** — `test/common/DocumentModule/DocumentModuleCommon.js` (now 13 tests) adds `testSetDocumentEmitsDocumentUpdated`, `testRemoveDocumentEmitsDocumentRemoved`, `testCannotSetDocumentWithZeroName` (`ERC1643InvalidName`) and `testCannotRemoveMissingDocument` (`ERC1643MissingDocument`). They run on both the native `DocumentERC1643Module` and the external `DocumentEngineModule` (which re-emits the events on the token and forwards the typed errors from the engine). `doc/test/Test.md` updated.

2. **Pagination (advisory).** `getAllDocuments` returns the whole array in one call. The rework §Security Considerations says implementations expecting large sets *should consider* a paginated accessor (as CMTAT already does for `HolderListModule` via `holdersInRange`). This is a `SHOULD-consider`, not a `MUST`; documents are typically few, so CMTAT deliberately leaves it unpaginated. **Documented** — the [module doc](../modules/extensions/documentEngine/document.md#getalldocuments--bytes32) now carries an explicit "unbounded read / keep the set small" note pointing at the ERC-1643 security consideration and contrasting with `HolderListModule`.

3. **NatSpec nit.** `draft-IERC1643.sol:39` documents `getAllDocuments`' return as *"An array of strings representing all document identifiers"* — it returns `bytes32[]`, not strings. Trivial wording fix.

---

## Summary

| Area | Result |
|---|---|
| Rework spec — all `MUST` | ✅ met |
| Rework spec — `SHOULD` (ERC-165, `bytes32(0)` error, `lastModified` sentinel) | ✅ met |
| Original draft | ✅ met (ABI-compatible superset) |
| ERC-165 detection | ✅ registered (`0xecfecec8`) |
| Authorization | ✅ `DOCUMENT_ROLE` |
| Recommended test cases | ✅ added (events, `name==0`, missing-doc) — 13 tests, both variants |
| Pagination | ✅ advisory; documented "keep the set small" (unpaginated by design) |
| NatSpec | ⚠️ one `@return` mislabels `bytes32[]` as "strings" (open) |

**Conclusion: CMTAT is conformant with ERC-1643 (both the rework draft and the original).** The remaining follow-up is the one-line NatSpec `@return` wording fix; the test-coverage and pagination-note gaps are now closed.
