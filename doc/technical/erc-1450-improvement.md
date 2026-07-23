# ERC-1450 — Possible Improvements & ERC-1643 Compatibility

> Review of [`erc-1450.md`](./../ERCSpecification/erc-1450.md) (Last Call, `requires: 20, 165, 6093`).
> Companion to [`erc-1450-integration.md`](./erc-1450-integration.md).

This document (1) collects suggested improvements to the ERC-1450 specification from a
CMTAT-implementer's perspective, and (2) answers whether ERC-1450 is compatible with the
**updated** ERC-1643 ([`update/erc-1643.md`](./../ERCSpecification/update/erc-1643.md)).

---

## Part 1 — Suggested improvements

### 1. The interface is monolithic — split it

`IERC1450` bundles, in a single interface, everything: ERC-20, an ERC-1643 document subset,
ERC-1644 controller operations, a fee engine, a broker registry, a transfer-request state
machine, recovery workflow, per-lot regulation tracking, account freezing, and optional
EIP-3668 pre-checks. The spec *says* many parts are OPTIONAL, but they all live in one
`IERC1450` type, so `type(IERC1450).interfaceId` cannot distinguish a minimal implementation
from a full one.

**Recommendation:** decompose into a required core plus discoverable extension interfaces,
each with its own ERC-165 id — e.g. `IERC1450Core`, `IERC1450Fees`, `IERC1450Broker`,
`IERC1450Requests`, `IERC1450Regulation`, and *reuse* `IERC1643` / `IERC1644` rather than
re-declaring them. This mirrors CMTAT's modular design and the way the updated ERC-1643 was
extracted into a standalone, independently-detectable interface.

### 2. `mint` / `burnFrom` signatures collide with de-facto standards

- `mint(address,uint256,uint16,uint256)` shadows the ubiquitous `mint(address,uint256)`; generic tooling/indexers that expect the 2-arg form will mis-decode.
- `burnFrom(address,uint256)` has the **exact selector** of OpenZeppelin `ERC20Burnable.burnFrom`, whose semantics are *allowance-based holder burn* — here it means *RTA strategic burn*. Same selector, opposite trust model. This is a real footgun for integrators.

**Recommendation:** rename the regulation-aware entrypoints (`mintRegulated`,
`burnRegulated`) and, if a plain `mint`/`burnFrom` is kept, give it standard semantics.

### 3. Three near-identical burn functions

`burnFrom`, `burnFromRegulated`, and `burnFromRegulation` differ only in how a lot is
selected. This is confusing and error-prone (wrong overload = wrong lot burned).

**Recommendation:** collapse to one `burnRegulated(from, amount, lotSelector)` where the
selector is a struct/enum (FIFO / LIFO / explicit `(regulationType, issuanceDate)`).

### 4. On-chain lot tracking contradicts the off-chain-authority premise

`getHolderRegulations` is specified as MUST-store-on-chain (spec line ~473), yet the same
document repeatedly states the RTA holds the *authoritative* cap table off-chain and that
on-chain document anchoring is "an optional transparency enhancement, not a compliance
requirement." Mandatory per-holder `TokenBatch[]` arrays are gas-heavy (unbounded array
growth, O(n) lot scans) and duplicate the RTA's own books.

**Recommendation:** make the on-chain lot **store** OPTIONAL; require only the
`TokensMinted` / `RegulatedTransfer` / `TokensBurned` **events** (which already "allow
reconstruction of the entire cap table from events"). Implementers who want lot views can
index events off-chain, matching the ERC's own stated audit-trail model.

### 5. Transfer-request lifecycle: idempotency & state-machine gaps

- `requestTransferWithFee` returns a `requestId` but the spec never says **how it is generated**, while simultaneously demanding idempotency ("each requestId is unique and can only be executed ONCE"). Non-deterministic ids (counter) and caller-supplied retries can't both hold.
- `updateRequestStatus(requestId, newStatus)` lets the RTA set an arbitrary status; the "MUST validate state transitions" wording is not encoded in the type, so nothing prevents `Executed → Requested`.

**Recommendation:** define `requestId = keccak256(from, to, amount, nonce, chainid)` (deterministic, replay-safe, cross-chain-unique), and specify the legal transition matrix explicitly (which transitions each function may perform).

### 6. Reusing ERC-6093 errors with *changed meaning* is misleading

The spec keeps `OwnableUnauthorizedAccount` / `OwnableInvalidOwner` "for tooling
compatibility" but redefines "Owner" to mean "Issuer" with inverted control (only the RTA
can change it). Tools that special-case Ownable errors will now be **actively wrong**.

**Recommendation:** use dedicated `ERC1450NotRTA` / `ERC1450InvalidIssuer` errors. Borrowing
a name while inverting its semantics is worse than a fresh error.

### 7. `allowance` MUST return 0 — but fees rely on allowance

`allowance` is forced to `0` and `approve` reverts on the security token, yet
`requestTransferWithFee` requires the caller to have `approve`d the **fee token**. The
security-token `approve` being disabled is fine, but the spec should state loudly that all
fee approvals are on the *fee* ERC-20, and that hard-zeroing `allowance()` can break naïve
aggregators that probe allowance before any interaction.

### 8. `preCheckCompliance` is `view` yet reverts with `OffchainLookup` *and* returns `bool`

A function typed `returns (bool)` that is expected to `revert OffchainLookup(...)` has a
contradictory contract: callers can't tell if `false` means "non-compliant" or "call the
callback." EIP-3668 lookups also shouldn't be `view` in a way that implies a pure boolean.

**Recommendation:** pick one shape — either a pure advisory `bool` view, or a CCIP-Read
function whose only success path is the callback. Don't overload both onto one signature.

### 9. Interface-ID derivation is not reproducible

The spec hard-codes `IERC1450_INTERFACE_ID = 0xaf175dee` but derives it from a truncated XOR
list ending in `/* ^ ... */`. No reader can independently recompute `0xaf175dee`.

**Recommendation:** publish the complete, ordered selector list (or, better, split
interfaces per §1 so each id is small and verifiable).

### 10. Fee custody lives inside the security token

`withdrawFees` implies the security-token contract *holds* collected fee-token balances,
mixing fee treasury with the register of ownership. That enlarges the security token's
attack surface and complicates accounting/audits.

**Recommendation:** route fees to a separate collector contract; keep the security token
free of unrelated ERC-20 custody.

### 11. `batch*` operations are all-or-nothing with no result map

`batchMint` / `batchTransferFrom` / `batchBurnFrom` revert entirely if any single item
fails. For large corporate actions (dividends over thousands of holders) one bad row aborts
the whole batch and wastes gas.

**Recommendation:** offer a variant that returns a success bitmap / per-item status instead
of reverting, letting the RTA reconcile failures out-of-band.

### 12. `regulationType` codes are non-normative → no cross-platform meaning

`uint16` regulation codes are "suggested, implementations may vary," so `0x0006` means Reg CF
in one deployment and anything elsewhere. Any cross-issuer tooling that keys off
`regulationType` is unreliable.

**Recommendation:** either normativize a registry (ideally an external, versioned registry
contract) or replace the raw code with a URI/DID pointer resolved off-chain.

---

## Part 2 — ERC-1643 compatibility

**Question:** Is ERC-1450 compatible with the *updated* ERC-1643
([`update/erc-1643.md`](./../ERCSpecification/update/erc-1643.md))?

**Answer: Yes — at the ABI/selector level the ERC-1450 document subset is a strict, wire-compatible subset of the updated ERC-1643.** A single contract can satisfy both, and CMTAT's existing `DocumentERC1643Module` already does. A handful of `SHOULD`-level semantics from the updated ERC-1643 are not mentioned by ERC-1450 and should be adopted for full conformance.

### 2.1 Selector-level match (compatible)

| Element | ERC-1450 (embedded) | Updated ERC-1643 | Compatible? |
|---|---|---|---|
| `setDocument(bytes32,string,bytes32)` | ✓ (`_name,_uri,_documentHash`) | ✓ (`name,uri,documentHash`) | **Yes** — param names don't affect the selector |
| `getDocument(bytes32)` → `(string,bytes32,uint256)` | returns `(documentUri, documentHash, timestamp)` | returns `(uri, documentHash, lastModified)` | **Yes** — identical selector *and* identical ABI return encoding |
| `removeDocument(bytes32)` | ✓ | ✓ | **Yes** |
| `getAllDocuments()` → `bytes32[]` | ✓ | ✓ | **Yes** |
| `event DocumentUpdated(bytes32 indexed,string,bytes32)` | ✓ | ✓ | **Yes** — identical topic0 |
| `event DocumentRemoved(bytes32 indexed,string,bytes32)` | ✓ | ✓ | **Yes** — identical topic0 |

So an ERC-1450 implementation's document functions are indistinguishable, on the wire, from
an updated-ERC-1643 implementation. Note ERC-1450 exposes only the 4 core functions — it
does not add anything that *conflicts* with ERC-1643.

### 2.2 CMTAT note — struct return is still ABI-identical

CMTAT's `IERC1643.getDocument` returns a `Document` **struct** `(string uri, bytes32
documentHash, uint256 lastModified)` rather than three separate values. In Solidity ABI
encoding a returned struct and three separate return values of the same types encode
**identically**, so CMTAT's document module is wire-compatible with *both* the updated
ERC-1643 tuple form and the ERC-1450 embedded form. No adapter needed.

### 2.3 Gaps to close for *full* conformance (not incompatibilities)

The updated ERC-1643 tightened several `SHOULD`/`MUST` semantics that ERC-1450 simply
doesn't mention. None conflict; ERC-1450 should adopt them:

1. **Custom errors.** Updated ERC-1643 defines `ERC1643InvalidName()` (reject
   `name == bytes32(0)` in `setDocument`) and `ERC1643MissingDocument()` (revert when
   `removeDocument` targets a missing entry). ERC-1450 says nothing, so a naïve
   implementation may accept the zero key or silently no-op on removal.
2. **`getDocument` MUST NOT revert on a missing entry** and MUST return empties
   (`""`, `bytes32(0)`, `0`). ERC-1450 leaves this unspecified.
3. **ERC-165 detection.** Updated ERC-1643 says `supportsInterface` SHOULD return `true`
   for `type(IERC1643).interfaceId`. ERC-1450's ERC-165 section only mandates the IERC1450
   id (and forbids the ERC-20 id) — it should *also* advertise `IERC1643` when the document
   extension is implemented. This is additive and does not clash with the "MUST NOT return
   true for ERC-20" rule.
4. **Timestamp semantics** already agree (last-modified, set on write); only the field name
   differs (`timestamp` vs `lastModified`) — cosmetic.

### 2.4 Recommendation

Because the updated ERC-1643 is now a standalone, reusable interface, ERC-1450 should stop
**re-declaring** the document functions inline and instead:

- add `1643` to its `requires:` list and `import`/inherit `IERC1643`, and
- adopt the ERC-1643 error set + no-revert-on-missing `getDocument` semantics + optional
  `IERC1643` ERC-165 id.

This removes drift risk (two copies of the same interface diverging over time) and lets
CMTAT — which already ships a conforming ERC-1643 module — back ERC-1450's document
requirement verbatim.

### 2.5 Compatibility summary

| Verdict | Detail |
|---|---|
| **ABI / selectors / events** | ✅ Fully compatible — ERC-1450 doc subset ⊆ updated ERC-1643 |
| **CMTAT `DocumentERC1643Module`** | ✅ Usable as-is (struct return is ABI-identical) |
| **Error semantics** | ⚠ ERC-1450 should adopt `ERC1643InvalidName` / `ERC1643MissingDocument` |
| **Missing-entry `getDocument`** | ⚠ ERC-1450 should specify no-revert + empty return |
| **ERC-165 `IERC1643` id** | ⚠ ERC-1450 should advertise it (additive; no conflict) |
