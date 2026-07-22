# ERC-1404 (rework, current version) — Final Conformance Analysis

**Spec analysed:** [`erc-1404.md`](./erc-1404.md) — the updated rework, in which the former
`spender == from` **equality MUST** has been replaced by a **SHOULD** (evaluate the
`spender == from` case through the spender-aware path) plus an **optional skip** for policies
that do not restrict operator identity. The Test Cases table now splits the `spender == from`
row accordingly (spec `:81`, `:143-144`).

**Supersedes:** [`erc-1404-analysis-rework.md`](./erc-1404-analysis-rework.md) and
[`ruleengine-erc1404-rework.md`](./ruleengine-erc1404-rework.md). See §5 for what changed.

**Code analysed (unchanged except the mock `supportsInterface` fix already applied):**

| Layer | File |
|-------|------|
| Interface / extension id | `contracts/interfaces/tokenization/draft-IERC1404.sol`, `contracts/library/ERC1404ExtendInterfaceId.sol` |
| Token reporting | `contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleERC1404.sol` |
| Token composition / 165 | `contracts/modules/4_CMTATBaseERC1404.sol` |
| Token enforcement | `ValidationModule.sol`, `0_CMTATBaseCommon.sol`, `3_CMTATBaseRuleEngine.sol`, `internal/ERC20EnforcementModuleInternal.sol` |
| Rule engine | `contracts/mocks/RuleEngine/RuleEngineMock.sol` + rules |

---

## 1. Verdict

Against the current spec, **both the CMTAT token and the RuleEngine mock are conformant.**

- The fundamental **enforcement-consistency MUST** (a transfer/`transferFrom` is rejected iff
  the corresponding predictor returns non-zero) holds on every path.
- Both ERC-165 identifiers (`0xab84a5c8`, `0x78a8de7d`) are advertised by both contracts.
- The former `spender == from` findings are **resolved by the spec change**: CMTAT and the
  operator-restricting rule (`RuleSpenderAuthorized`) correctly evaluate `spender == from`
  through the spender-aware path, which the new text explicitly endorses (`:81`).

One **informational** item remains: the rule engine's `messageForTransferRestriction(0)`
returns `"UnknownRestrictionCode"` rather than a no-restriction string (§4.3 / §3.4 below).
Everything else is a positive.

---

## 2. Effect of the spec change

The old text required `detectTransferRestrictionFrom(from, from, …) == detectTransferRestriction(from, …)`.
The new text (`:81`) instead:

- **SHOULD** evaluate `spender == from` through the spender-aware path (treat `transferFrom` as a
  delegated transfer even when the initiator equals `from`);
- **MAY** skip the spender-specific checks for `spender == from` **only** when observably
  equivalent (no operator-identity restriction);
- **MUST NOT** skip when the policy restricts the operator identity, because skipping would
  report `0` for a self-`transferFrom` that reverts.

Both CMTAT and the mock restrict the operator identity (frozen spender / allow-listed spender),
so the binding rule for them is "**MUST NOT skip**" — and neither skips. What used to be a MUST
violation is now the required behaviour.

---

## 3. CMTAT token

### 3.1 Mandatory methods — CONFORMANT
- `detectTransferRestriction` (`ValidationModuleERC1404.sol:98`), `messageForTransferRestriction`
  (`:52`, override `4_CMTATBaseERC1404.sol:31`). `messageForTransferRestriction(0)` →
  `"NoRestriction"` (`:56`). ✓

### 3.2 Spender-aware extension & the `spender == from` case — CONFORMANT
`detectTransferRestrictionFrom` (`ValidationModuleERC1404.sol:114`) evaluates
`isFrozen(spender)` first (`:121`), then the base `from`/`to`/`value` conditions (`:124`), then
delegates to `ruleEngine.detectTransferRestrictionFrom(spender, …)` (`:128`). It does **not**
short-circuit `spender == from`, so a self-initiated `transferFrom` by a frozen holder is
reported as `SPENDER_FROZEN` (`:121-122`) — which is exactly what enforcement does (see 3.3).

This satisfies the new SHOULD (`:81`): CMTAT is an operator-restricting policy (a frozen
`spender` cannot operate), so it is in the "MUST NOT skip" class, and it correctly keeps the
spender-aware path. The divergence from `detectTransferRestriction` for `spender == from` is now
**explicitly permitted** (`:144`).

> Note: the short-circuit fix recommended in the *previous* analysis is **withdrawn** — under the
> current spec it would be the prohibited skip (`:81`, Security Considerations `:232`), turning a
> permitted code difference into a report-`0`-then-revert divergence.

### 3.3 Enforcement consistency (the binding MUST) — CONFORMANT
CMTAT enforces by re-evaluating conditions (typed ERC-7943 reverts), the spec's permitted
alternative to calling the detector directly (`:50`). Reporting and enforcement check the same
predicates, so both reject iff any fails:

| Predicate | `detectTransferRestrictionFrom` | `transferFrom` enforcement |
|-----------|--------------------------------|----------------------------|
| `isFrozen(spender)` | `:121` | `_canTransferisFrozenAndRevert` (`ValidationModule.sol:143`) |
| active balance of `from` | `:124` → `_checkActiveBalance` (`4_CMTATBaseERC1404.sol:98`) | `_checkActiveBalanceAndRevert` (`ERC20EnforcementModuleInternal.sol:140`) |
| paused / deactivated | `:124` (`_detectTransferRestriction`) | `_requireNotPaused` (`ValidationModule.sol:175`); `deactivated ⇒ paused` invariant (`PauseModule.sol:70,86`) |
| `isFrozen(from)` / `isFrozen(to)` | `:124` | `ValidationModule.sol:145,147` |
| rule engine | `ruleEngine.detectTransferRestrictionFrom` (`:128`) | `ruleEngine.transferred(spender,…)` → `detectTransferRestrictionFrom` (`ValidationModuleRuleEngine.sol:143`, `RuleEngineMock.sol:130`) |

Same for the base pair (`transfer` routes `spender = address(0)` → 3-arg `transferred` →
`detectTransferRestriction`). Reject-iff-non-zero holds; the check *order* differs but the MUST
is about agreement, not code identity. ✓

### 3.4 ERC-165 — CONFORMANT (verified)
`supportsInterface` (`4_CMTATBaseERC1404.sol:75`) returns `true` for `type(IERC1404).interfaceId`
(= `0xab84a5c8`, valid because the repo's `IERC1404` does not inherit `IERC20`) and for
`ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID` (`0x78a8de7d`, the hand-computed 3-selector
XOR — correctly *not* `type(IERC1404Extend).interfaceId`, per spec `:91`). Both verified by
recomputation in the prior analysis. ✓

---

## 4. RuleEngine mock

The spec (`:101`) explicitly permits a compliance contract to implement the restriction
interface without being a token — which is exactly what `RuleEngineMock` is.

### 4.1 ERC-165 — CONFORMANT (fix applied)
`supportsInterface` (`RuleEngineMock.sol:177-179`) now returns `true` for
`type(IERC1404).interfaceId` (`0xab84a5c8`), `ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID`
(`0x78a8de7d`), the rule-engine id (`0x20c49ce7`), and ERC-165. The mandatory-id omission flagged
in the previous analysis (§4.1) is **fixed** and covered by a test
(`ValidationModuleSetRuleEngineCommon.js`, `testCanReturnTheRightInterface`). ✓

### 4.2 `spender == from` via the rules — CONFORMANT (now intended)
`detectTransferRestrictionFrom` (`RuleEngineMock.sol:82`) iterates each rule's 4-arg form:
- `RuleSpenderAuthorized` (`:37-47`) restricts the operator identity → it does **not** skip
  `spender == from`; `detectTransferRestrictionFrom(from, from, …)` returns
  `SPENDER_NOT_AUTHORIZED` (21) while `detectTransferRestriction(from, …)` returns `0`. Under the
  current spec this divergence is **permitted** (`:144`) and is consistent with enforcement (the
  self-`transferFrom` reverts via `transferred` → `canTransferFrom` → 21, `:130`). ✓
- `RuleMock` / `RuleMockMint` do not restrict operator identity, so they delegate their `From`
  variant straight to `detectTransferRestriction` (`RuleMock.sol:44`, `RuleMockMint.sol:43`) —
  the allowed optimization skip (`:81`). ✓

The previous §4.2 finding is therefore **resolved by the spec change**, not by a code change.

### 4.3 `messageForTransferRestriction(0)` — INFORMATIONAL (open)
`messageForTransferRestriction` (`RuleEngineMock.sol:151`) has no rule claiming code `0`, so it
falls through to `"UnknownRestrictionCode"` (`:164`). The Test Cases table still expects code `0`
to yield a no-restriction string (`:152`). Masked on the token (which maps `TRANSFER_OK` first),
but the spec allows the engine to be consulted directly (`:101`), where `0` should read as "no
restriction", not "unknown". Deterministic, so **informational**, not a MUST break.

**Fix:** `if (_restrictionCode == 0) return "NoRestriction";` at the top of the function, plus a
test asserting it.

### 4.4 Enforcement consistency — CONFORMANT
The engine uses the spec's RECOMMENDED strategy: `transferred` invokes the detector directly
(`RuleEngineMock.sol:130,138`), so reporting and enforcement cannot drift within the engine. ✓

---

## 5. What changed since the previous analyses

| Item | Previous verdict | Now |
|------|------------------|-----|
| Token `spender == from` code differs from base (`erc-1404-analysis-rework.md` §4) | ❌ MUST violation | ✅ Conformant — permitted by new `:81`/`:144`; short-circuit fix **withdrawn** |
| Mock `spender == from` via `RuleSpenderAuthorized` (`ruleengine-…` §4.2) | ❌ MUST violation | ✅ Conformant — intended, operator-restricting policy |
| Mock `supportsInterface` missing `0xab84a5c8` (§4.1) | ❌ MUST violation | ✅ **Fixed** in code + test |
| Mock `messageForTransferRestriction(0)` (§4.3) | ⚠ Informational | ⚠ Informational (still open) |

---

## 6. Remaining suggestions

1. **(Mock, informational)** Return a no-restriction string for code `0` in
   `RuleEngineMock.messageForTransferRestriction` (§4.3), with a test.
2. **(Both, robustness)** Add the enforcement-consistency invariant as a fuzz test — the spec's
   SHOULD (`:228`): over random `(spender, from, to, value)` and state, assert
   `detectTransferRestrictionFrom(s,f,t,v) == 0` **iff** `transferFrom(f,t,v)` by `s` succeeds,
   and the base pair likewise. Because CMTAT uses the re-evaluate strategy, this locks the two
   codepaths together. (Do **not** assert `spender == from` equality — the spec no longer requires
   it, and asserting it would contradict the operator-restricting policies.)
3. **(Both, docs)** Add a one-line comment at `ValidationModuleERC1404.detectTransferRestrictionFrom`
   and in `RuleSpenderAuthorized` noting the deliberate non-skip for `spender == from` and citing
   spec `:81`, so a future "optimization" doesn't reintroduce the prohibited skip.
4. **(Mock, housekeeping)** Restriction-code namespacing: rules use `13/20/21`, clear of the
   reserved `0–12`; keep a single table of allocated codes to avoid collisions in the `uint8`
   space (spec `:107`).

---

## 7. Summary tables

### CMTAT token
| Requirement (current spec) | Status |
|----------------------------|--------|
| `detectTransferRestriction` / `messageForTransferRestriction` present, `0` = OK | ✅ |
| Enforcement consistent with base method | ✅ (re-evaluate strategy) |
| `detectTransferRestrictionFrom` present | ✅ |
| `spender == from` via spender-aware path (SHOULD; MUST NOT skip for operator-restricting policy) | ✅ |
| `detectTransferRestrictionFrom` consistent with `transferFrom` enforcement | ✅ |
| ERC-165 `0xab84a5c8` and `0x78a8de7d` advertised | ✅ (verified) |
| Determinism | ✅ |

### RuleEngine mock
| Requirement (current spec) | Status |
|----------------------------|--------|
| Restriction interface as a non-token compliance contract | ✅ (`:101`) |
| Three methods present; enforcement invokes detectors directly | ✅ |
| ERC-165 `0xab84a5c8` (mandatory) | ✅ (fixed) |
| ERC-165 `0x78a8de7d` (extension), via explicit XOR constant | ✅ |
| `spender == from` handled per policy, consistent with enforcement | ✅ |
| `messageForTransferRestriction(0)` returns a no-restriction string | ⚠ returns `"UnknownRestrictionCode"` (informational) |
| Determinism / namespaced codes | ✅ |
