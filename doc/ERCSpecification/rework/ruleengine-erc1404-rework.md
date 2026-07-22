# RuleEngine Mock — ERC-1404 (rework) Conformance Analysis

**Scope:** checks whether the reference `RuleEngineMock` (and its rules) correctly
implements [`doc/ERCSpecification/rework/erc-1404.md`](./erc-1404.md), the reworked draft
that adds the optional spender-aware extension. Companion to
[`erc-1404-analysis-rework.md`](./erc-1404-analysis-rework.md) (which covers the CMTAT
token side).

**Files reviewed**

| Role | File |
|------|------|
| Aggregating compliance contract | `contracts/mocks/RuleEngine/RuleEngineMock.sol` |
| Rule interface | `contracts/mocks/RuleEngine/interfaces/IRule.sol` (`IRule is IERC1404Extend, IERC3643ComplianceRead`) |
| Rules | `RuleMock.sol`, `RuleMockMint.sol`, `RuleSpenderAuthorized.sol`, `RuleTokenHolderTracker.sol`, `CodeList.sol` |
| Interface ids | `contracts/library/ERC1404ExtendInterfaceId.sol` (`0x78a8de7d`), `RuleEngineInterfaceId.sol` (`0x20c49ce7`) |
| Engine interface | `contracts/interfaces/engine/IRuleEngine.sol` (`IRuleEngineERC1404 is IERC1404Extend, IRuleEngine`) |

The spec explicitly contemplates this shape (§Additional Specifications):

> Compliance-related contracts (for example, a rule engine or compliance module) MAY
> implement the ERC-1404 restriction interface without implementing any token interface
> at all … the contract is expected to be consulted by a token or other caller that
> performs the actual transfer.

So the `RuleEngineMock` is a legitimate "ERC-1404 compliance contract that is not a
token," and the standard's `detectTransferRestriction` / `messageForTransferRestriction`
(and, since it exposes it, `detectTransferRestrictionFrom`) semantics apply to it.

---

## 1. Verdict

The `RuleEngineMock` implements all three restriction methods and its enforcement hook
(`transferred`) is consistent-by-construction with its reporting methods (it literally
calls them). However there are **two normative (MUST) deviations** from the rework:

1. **`supportsInterface` does not advertise the mandatory ERC-1404 id `0xab84a5c8`** — it
   advertises only the extension id `0x78a8de7d`. (§4.1)
2. **The `spender == from` degenerate case of `detectTransferRestrictionFrom` does not
   equal `detectTransferRestriction`**, caused by `RuleSpenderAuthorized`. (§4.2)

Plus one low/informational issue: `messageForTransferRestriction(0)` does not return a
"no restriction" message. (§4.3)

Because the reference token (CMTAT) also carries its own copy of both issues (see the
companion analysis), fixing them in the mock keeps the reference material self-consistent.

---

## 2. Mandatory + extension methods — PRESENT

| Method | Location | Notes |
|--------|----------|-------|
| `detectTransferRestriction(address,address,uint256)` | `RuleEngineMock.sol:62` | Iterates rules, returns first non-zero code, else `TRANSFER_OK` (0). ✓ |
| `messageForTransferRestriction(uint8)` | `RuleEngineMock.sol:150` | Iterates rules via `canReturnTransferRestrictionCode`, deterministic, `"UnknownRestrictionCode"` fallback. (see §4.3) |
| `detectTransferRestrictionFrom(address,address,address,uint256)` | `RuleEngineMock.sol:82` | Iterates rules' 4-arg form, returns first non-zero. (see §4.2) |

Codes returned by the rules are `13` (`AMOUNT_TOO_HIGH`), `20` (`MINT_TOO_HIGH`),
`21` (`SPENDER_NOT_AUTHORIZED`) — all `≥ 13`, so they avoid the `0–6` range reserved by
`IERC1404Extend.REJECTED_CODE_BASE` and the `7–12` range the interface comment reserves
for CMTAT. Good namespacing within the 256-value `uint8` space (the spec's code-space
caution, §Security Considerations).

---

## 3. Enforcement consistency — CONFORMANT (RECOMMENDED strategy)

Unlike the token (which re-evaluates conditions), the rule engine uses the spec's
**RECOMMENDED** strategy — enforcement invokes the detector directly, so reporting and
enforcement cannot drift:

- `transferred(spender, from, to, value)` (`:125`) → `require(canTransferFrom(...))`
  (`:130`) → `canTransferFrom` (`:112`) → `detectTransferRestrictionFrom(...) == 0`.
- `transferred(from, to, value)` (`:134`) → `require(canTransfer(...))` (`:138`) →
  `canTransfer` (`:104`) → `detectTransferRestriction(...) == 0`.

The token routes standard transfers to the 3-arg `transferred` (spender `0`) and
`transferFrom` to the 4-arg `transferred` (`ValidationModuleRuleEngine.sol:142`), so the
engine's enforcement matches the correct reporting method in each case. The base
method's "reject iff non-zero code" MUST is satisfied by construction. ✓

Checks are `pure`/`view` over rule state only (amount thresholds, immutable authorized
spender, tracked balances) — deterministic, no counterparty-manipulable inputs. ✓

---

## 4. Findings

### 4.1 [MUST] `supportsInterface` omits the mandatory ERC-1404 id `0xab84a5c8` — Severity: Low–Medium

`RuleEngineMock.supportsInterface` (`:166`):

```solidity
return interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID      // 0x20c49ce7
    || interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID // 0x78a8de7d
    || super.supportsInterface(interfaceId);                              // ERC165 only
```

`super` (`ERC165`) resolves only `0x01ffc9a7`. So:

| `supportsInterface(id)` | Result | Spec requirement |
|--------------------------|--------|------------------|
| `0x01ffc9a7` (ERC-165) | `true` | ✅ |
| `0x78a8de7d` (extension) | `true` | ✅ |
| `0xab84a5c8` (**mandatory ERC-1404**) | **`false`** | ❌ MUST be `true` |

The rework is explicit (§Extension): an implementation that exposes
`detectTransferRestrictionFrom` **and** supports ERC-165

> - MUST return `true` for `0xab84a5c8`, exactly as a non-extended implementation does —
>   the mandatory interface is still fully present, so a base-only integrator continues
>   to detect it.
> - MUST return `true` for `0x78a8de7d` …

The mock satisfies the second MUST but not the first. **Consequence:** an integrator that
only knows the base ERC-1404 (probes `0xab84a5c8`) fails to recognise the rule engine as
ERC-1404-capable, even though it fully implements both mandatory methods — exactly the
regression the spec's dual-id design exists to prevent. Note this also makes the mock
*inconsistent with the CMTAT token*, whose `supportsInterface` correctly returns `true`
for both ids (`4_CMTATBaseERC1404.sol:79-81`).

**Fix:**

```solidity
return interfaceId == type(IERC1404).interfaceId                          // 0xab84a5c8
    || interfaceId == ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID // 0x78a8de7d
    || interfaceId == RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID
    || super.supportsInterface(interfaceId);
```

(`type(IERC1404).interfaceId` == `0xab84a5c8` here because the repo's `IERC1404` does not
inherit `IERC20` — same reasoning as on the token side. A literal `0xab84a5c8` is
equivalent.)

### 4.2 [MUST] `spender == from` code equality violated by `RuleSpenderAuthorized` — Severity: Low

Spec §Extension (second bullet) and the Test Cases row "`spender == from` → Equal to
`detectTransferRestriction(from, to, value)`" require that, for `spender == from`, the two
predictors return the **same code**.

`RuleEngineMock.detectTransferRestrictionFrom` (`:82`) iterates each rule's 4-arg form
without special-casing `spender == from`. Most rules are safe — `RuleMock` and
`RuleMockMint` delegate their `From` variant straight to `detectTransferRestriction`
(`RuleMock.sol:44-46`, `RuleMockMint.sol:43-45`), and `RuleTokenHolderTracker` is
permissive. But `RuleSpenderAuthorized` breaks the equality:

- `RuleSpenderAuthorized.detectTransferRestriction(...)` → always `0` (`:29-35`).
- `RuleSpenderAuthorized.detectTransferRestrictionFrom(spender,...)` → `SPENDER_NOT_AUTHORIZED`
  (`21`) when `spender != 0 && spender != authorizedSpender` (`:37-47`).

So with `spender == from == someHolder` (not the authorized spender):

- `RuleEngineMock.detectTransferRestrictionFrom(from, from, to, v)` → **21**
- `RuleEngineMock.detectTransferRestriction(from, to, v)` → **0**

`21 ≠ 0` → **MUST violated.** Unlike the token-side instance (§4 of the companion doc,
which was frozen-holder only), here it has a **behavioural** consequence via enforcement:
a holder calling `transferFrom` on their own tokens (`spender == from`) is *rejected* by
the engine (`transferred` → `canTransferFrom` → `21` → revert), while a plain `transfer`
succeeds. That divergence is invisible to `detectTransferRestriction`, which reports `0`.

This is still **Low severity** against the *base* method (the base method's consistency is
defined over `from`/`to`/`value` and is explicitly allowed to be blind to the spender), but
it is a clear violation of the *extension's* degenerate-case MUST.

Root cause: `RuleSpenderAuthorized`'s policy ("only `authorizedSpender` may ever initiate a
delegated transfer") intentionally wants to reject even the holder's own `transferFrom`,
which is fundamentally at odds with the spec's `spender == from` MUST.

**Fix (choose one):**
- *Aggregator-level (robust, mirrors the recommended token fix):* short-circuit in
  `RuleEngineMock.detectTransferRestrictionFrom` — `if (spender == from) return detectTransferRestriction(from, to, value);`
  This guarantees the MUST regardless of any rule's spender logic.
- *Rule-level:* in `RuleSpenderAuthorized.detectTransferRestrictionFrom`, also allow
  `spender == from` (add `|| spender == _from`). This keeps the rule individually
  conformant.

Add a test asserting `detectTransferRestrictionFrom(x, x, y, v) == detectTransferRestriction(x, y, v)`
over the full rule set.

### 4.3 [Info] `messageForTransferRestriction(0)` does not return a "no restriction" message — Severity: Informational

`messageForTransferRestriction` (`:150`) scans rules for one whose
`canReturnTransferRestrictionCode(code)` is `true`; none claims code `0`, so it returns the
`"UnknownRestrictionCode"` fallback (`:163`). The rework Test Cases table expects
`messageForTransferRestriction(0)` to yield "a deterministic human-readable string
indicating no restriction (e.g. `"No restriction"`)".

On the token this is masked (CMTAT maps `TRANSFER_OK` before delegating,
`ValidationModuleERC1404.sol:56`), but the spec explicitly allows the rule engine to be
consulted *directly* as a standalone compliance contract — and queried directly, code `0`
returns `"UnknownRestrictionCode"`, which reads as an error rather than "no restriction".
It is still deterministic, so this is informational, not a MUST break.

**Fix:** handle `TRANSFER_OK` first, e.g.
`if (_restrictionCode == 0) return "NoRestriction";` at the top of the function.

---

## 5. Positives

- All three restriction methods present; enforcement (`transferred`) invokes them
  directly — the spec's **RECOMMENDED** consistency-by-construction pattern.
- Correctly uses the hand-computed `ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID`
  constant rather than `type(IERC1404Extend).interfaceId`, avoiding the single-selector
  trap the spec warns about (§Extension).
- Deterministic, state-only checks; restriction codes namespaced clear of the reserved
  `0–12` range.
- Rules that are spender-agnostic (`RuleMock`, `RuleMockMint`) correctly delegate their
  `From` variant to the base detector, satisfying `spender == from` trivially.

---

## 6. Suggestions

### Implementation (mock)
1. Add `0xab84a5c8` to `supportsInterface` (§4.1) — makes the mock match the token and the
   spec's dual-id MUST.
2. Short-circuit `spender == from` in `RuleEngineMock.detectTransferRestrictionFrom`
   (§4.2), and/or allow `spender == from` in `RuleSpenderAuthorized`.
3. Return a no-restriction message for code `0` in `messageForTransferRestriction` (§4.3).
4. Add tests: `supportsInterface(0xab84a5c8) == true`; the `spender == from` equivalence
   over the rule set; `messageForTransferRestriction(0)` is a no-restriction string.

### Standard
- This mock is a second, independent data point (alongside the token) that the
  `spender == from` **code-equality** MUST is easy to violate whenever an implementation
  has a genuine "spender frozen / spender not authorized" policy: the natural design wants
  to report the spender-specific reason even when the spender happens to be the holder. The
  companion analysis §6.2 recommends the spec either relax this to reject/allow equivalence
  for `spender == from`, or explicitly mandate the short-circuit and show it in the
  reference implementation. `RuleSpenderAuthorized` is a concrete rule whose intended
  semantics directly collide with the current wording.

---

## 7. Summary table

| Requirement (rework) | RuleEngineMock |
|----------------------|----------------|
| `detectTransferRestriction` present, `0` = OK | ✅ |
| `messageForTransferRestriction` present, deterministic | ✅ (but code `0` → `"UnknownRestrictionCode"`, §4.3) |
| `detectTransferRestrictionFrom` present | ✅ |
| Enforcement consistent with reporting (reject iff non-zero) | ✅ (invokes detectors directly) |
| ERC-165 `0x01ffc9a7` | ✅ |
| ERC-165 **mandatory** `0xab84a5c8` | ❌ **MUST violation (§4.1)** |
| ERC-165 **extension** `0x78a8de7d`, via explicit XOR constant | ✅ |
| `spender == from` ⇒ same code as `detectTransferRestriction` | ❌ **MUST violation (§4.2)** |
| Deterministic / namespaced codes | ✅ |
