# ERC-1404 (rework) — Conformance Analysis of the CMTAT Implementation

**Scope:** compares the CMTAT ERC-1404 implementation against
[`doc/ERCSpecification/rework/erc-1404.md`](./erc-1404.md) (the reworked draft that
adds the optional spender-aware extension).

**Files reviewed**

| Layer | File |
|-------|------|
| Interface | `contracts/interfaces/tokenization/draft-IERC1404.sol` (`IERC1404`, `IERC1404Extend`) |
| Extension id | `contracts/library/ERC1404ExtendInterfaceId.sol` |
| Reporting logic | `contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleERC1404.sol` |
| Composition / 165 / active balance | `contracts/modules/4_CMTATBaseERC1404.sol` |
| Enforcement path | `contracts/modules/wrapper/controllers/ValidationModule.sol`, `0_CMTATBaseCommon.sol`, `3_CMTATBaseRuleEngine.sol`, `internal/ERC20EnforcementModuleInternal.sol` |
| Reference rule engine | `contracts/mocks/RuleEngine/RuleEngineMock.sol`, `RuleSpenderAuthorized.sol` |

---

## 1. Verdict

The implementation is **substantially conformant**. Both mandatory methods and the
optional spender-aware extension are present, both ERC-165 identifiers are computed
correctly and advertised, and the enforcement path is consistent with the reporting
path in the reject/allow sense the standard requires.

One **normative (MUST) deviation** was found: the `spender == from` degenerate case of
`detectTransferRestrictionFrom` does **not** return the same code as
`detectTransferRestriction`, violating the extension's second MUST clause and the
corresponding row of the Test Cases table. Details in §4.

---

## 2. Mandatory interface — CONFORMANT

### `detectTransferRestriction(address,address,uint256)`
Implemented at `ValidationModuleERC1404.sol:98`. Returns `0` (`TRANSFER_OK`) when
unrestricted, otherwise a `uint8` code. It layers CMTAT-native checks
(`deactivated`, `paused`, `isFrozen(from)`, `isFrozen(to)`, insufficient active
balance) over an optional rule-engine delegation, exactly the "issuer-defined policy"
the spec describes.

### `messageForTransferRestriction(uint8)`
Implemented at `ValidationModuleERC1404.sol:52` (+ override in
`4_CMTATBaseERC1404.sol:31` for the active-balance code). Deterministic, pure
string lookup; delegates unknown codes to the rule engine and falls back to
`"UnknownCode"`. Code `0` → `"NoRestriction"`. Conformant (the spec's example string
`"No restriction"` is non-normative).

### Enforcement consistency — CONFORMANT (via the "re-evaluate" path)
The spec permits two strategies (§Specification): call `detectTransferRestriction`
inside the transfer, **or** re-evaluate the equivalent conditions and revert with typed
errors, "provided the observable outcome remains consistent." CMTAT uses the second
strategy — `transfer`/`transferFrom` route through `_checkTransferred` →
`_canTransferGenericByModuleAndRevert` (`ValidationModule.sol:59`) and the rule
engine's `transferred`, reverting with ERC-7943 typed errors rather than a code.

The two codepaths re-evaluate the **same predicates** in the same order:

| Condition | Reporting (`_detectTransferRestriction`) | Enforcement |
|-----------|------------------------------------------|-------------|
| insufficient active balance | `4_CMTATBaseERC1404.sol:98` (`_checkActiveBalance`) | `_checkActiveBalanceAndRevert` (`ERC20EnforcementModuleInternal.sol:140`) |
| paused | `ValidationModuleERC1404.sol:149` | `_requireNotPaused` (`ValidationModule.sol:175`) |
| `isFrozen(from)` / `isFrozen(to)` | `:151` / `:153` | `_canTransferisFrozenAndRevert` (`ValidationModule.sol:138`) |
| rule engine | `ruleEngine.detectTransferRestriction` (`:108`) | `ruleEngine.transferred` (`ValidationModuleRuleEngine.sol:143`) |

Both **reject iff** at least one predicate fails, satisfying the base method's MUST.
This is a good design — it reuses `_checkActiveBalance` for both paths
(`4_CMTATBaseERC1404.sol:88` documents this intent), so the two cannot drift on the
frozen-balance dimension.

> **Note (not a bug):** `detectTransferRestriction` returns
> `TRANSFER_REJECTED_DEACTIVATED` for a deactivated contract
> (`ValidationModuleERC1404.sol:147`), but the standard-transfer enforcement path
> checks only `paused`, not `deactivated` (`ValidationModule.sol:171` comment). This
> stays consistent **only because** of the invariant `deactivated ⇒ paused`, enforced
> by `deactivateContract()` requiring the paused state (`PauseModule.sol:86`) and
> `unpause()` reverting while deactivated (`PauseModule.sol:70`). The consistency
> therefore relies on that invariant rather than on the two paths checking the same
> flag. See suggestion §6.2.

---

## 3. Optional spender-aware extension — MOSTLY CONFORMANT

### ERC-165 identifiers — CONFORMANT (verified)
Selectors and identifiers were recomputed from scratch:

| Selector | Value |
|----------|-------|
| `detectTransferRestriction(address,address,uint256)` | `0xd4ce1415` |
| `messageForTransferRestriction(uint8)` | `0x7f4ab1dd` |
| `detectTransferRestrictionFrom(address,address,address,uint256)` | `0xd32c7bb5` |
| **Mandatory id** = XOR of first two | **`0xab84a5c8`** ✓ |
| **Extension id** = XOR of all three | **`0x78a8de7d`** ✓ |

- `supportsInterface` (`4_CMTATBaseERC1404.sol:75`) returns `true` for **both**
  `0xab84a5c8` and `0x78a8de7d`, exactly as the spec requires (a base-only integrator
  still detects the mandatory id).
- The mandatory id is taken from `type(IERC1404).interfaceId`, which is correct here
  **only because** the repo's `IERC1404` (`draft-IERC1404.sol:9`) deliberately does
  *not* inherit `IERC20` — so the type-level id covers exactly the two mandatory
  selectors and equals `0xab84a5c8`.
- The extension id is taken from the **hand-computed constant**
  `ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID` (`:15`), **not** from
  `type(IERC1404Extend).interfaceId`. This is precisely the point the spec calls out in
  §Extension ("a language-level construct that derives an interface identifier only
  from a type's *directly declared* methods … MUST NOT be used"): `IERC1404Extend`
  inherits `IERC1404`, so `type(...).interfaceId` would yield only the single selector
  `0xd32c7bb5`. The implementation avoids the trap correctly, and the code comment at
  `4_CMTATBaseERC1404.sol:70-72` explains why. **Well done.**

### Delegated-transfer enforcement consistency — CONFORMANT
`transferFrom` enforcement additionally checks `isFrozen(spender)`
(`ValidationModule.sol:143`) and the rule engine's 4-arg `transferred`.
`detectTransferRestrictionFrom` (`ValidationModuleERC1404.sol:114`) mirrors this:
`isFrozen(spender)` → base predicates → `ruleEngine.detectTransferRestrictionFrom`.
Reject-iff-nonzero holds for the 4-argument form.

---

## 4. FINDING — `spender == from` code equality (MUST violation) — Severity: Low

**Spec requirement** (§Extension, second bullet, and the Test Cases row
"`spender == from` → Equal to `detectTransferRestriction(from, to, value)`"):

> MUST, when `spender == from`, return the same code as
> `detectTransferRestriction(from, to, value)`, since a direct transfer is the
> degenerate delegated transfer whose initiator is the holder.

The current `detectTransferRestrictionFrom` does **not** satisfy this. It checks
`isFrozen(spender)` first and, on any spender-specific policy, returns a
spender-specific code — even when `spender == from`. Two concrete divergences:

**(a) Frozen holder, self-initiated `transferFrom`.** With `spender == from` and `from`
frozen:
- `detectTransferRestrictionFrom(from, from, to, v)` → `isFrozen(spender)` true →
  returns `TRANSFER_REJECTED_SPENDER_FROZEN` = **5** (`ValidationModuleERC1404.sol:121-122`).
- `detectTransferRestriction(from, to, v)` → `isFrozen(from)` true → returns
  `TRANSFER_REJECTED_FROM_FROZEN` = **3** (`ValidationModuleERC1404.sol:151-152`).
- `5 ≠ 3` → **MUST violated.**

**(b) Rule-engine spender policy.** When `spender == from`, the method still delegates
to `ruleEngine.detectTransferRestrictionFrom(spender, …)` (`:128`) rather than
`ruleEngine.detectTransferRestriction(…)`. With the shipped `RuleSpenderAuthorized`
mock, a holder who is not the authorized spender gets code **21**
(`RuleSpenderAuthorized.sol:46`) from the `From` variant but **0** from the base
variant — again unequal.

**Impact.** Enforcement itself stays correct: in both cases the self-transfer is still
*rejected* (frozen) or the divergence is confined to the mock's non-production policy,
so the reject/allow consistency MUST is **not** broken. What breaks is the **code-equality
MUST** for the degenerate case — an integrator that trusts the spec's guarantee "for
`spender == from`, the two predictors agree" will mis-map the reason code (e.g. show
"spender frozen" where the base method says "holder frozen"). Hence **Low severity**:
a conformance/reporting defect, not an enforcement bug.

**Reachability through `transferFrom` (why the enforcement impact is narrow).** OpenZeppelin's
ERC-20 has **no** `spender == from` special case. `ERC20Upgradeable.transferFrom`
(`ERC20Upgradeable.sol:165`) unconditionally calls `_spendAllowance(from, msg.sender, value)`
before `_transfer`, and `_spendAllowance` (`:319`) consumes `allowance(from, spender)`:

```solidity
function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, value);   // no `if (spender == from)` bypass
    _transfer(from, to, value);
    return true;
}
```

So when the holder is the caller (`spender == from`), OZ still spends the holder's
*self-allowance* `allowance(from, from)`, which is `0` by default. A holder calling
`transferFrom(self, to, value)` therefore **reverts with `ERC20InsufficientAllowance(from, 0, value)`**
unless they have explicitly done `approve(self, …)` (and if that self-allowance is
`type(uint256).max`, `:321` skips the decrement). CMTAT runs its restriction checks *before*
this allowance logic (`0_CMTATBaseCommon.sol:92` → `ERC20BaseModule.transferFrom` → OZ), so the
`spender == from` branch of `detectTransferRestrictionFrom` is reached through a real
`transferFrom` only in the narrow case where the holder has self-approved.

This narrows the *enforcement* exposure but does **not** downgrade the finding: the spec's
`spender == from` MUST is stated over the **view function's return value**, unconditionally.
`detectTransferRestrictionFrom` is public and can be called with `spender == from` regardless
of any allowance, and integrators are told to trust that it agrees with
`detectTransferRestriction` in that case — reachability through `transferFrom` does not gate
the conformance obligation.

**Fix (one line, guarantees the MUST regardless of the rule engine):** short-circuit the
degenerate case at the top of `detectTransferRestrictionFrom`:

```solidity
function detectTransferRestrictionFrom(
    address spender, address from, address to, uint256 value
) public view virtual override(IERC1404Extend) returns (uint8 code) {
    if (spender == from) {
        // degenerate delegated transfer == direct transfer (ERC-1404 extension MUST)
        return detectTransferRestriction(from, to, value);
    }
    IRuleEngineERC1404 ruleEngine_ = IRuleEngineERC1404(address(ruleEngine()));
    if (isFrozen(spender)) {
        return uint8(IERC1404Extend.REJECTED_CODE_BASE.TRANSFER_REJECTED_SPENDER_FROZEN);
    }
    ...
}
```

This matches the enforcement path **for the frozen dimension**: when `spender == from`,
the `isFrozen(spender)` and `isFrozen(from)` checks in `_canTransferisFrozenAndRevert`
collapse to the same single revert, so reporting the `from` code is the faithful
reflection of what enforcement does.

> **⚠ The short-circuit is not unconditionally safe.** Routing `spender == from` to the
> non-spender-aware `detectTransferRestriction` **skips any rule-engine rule that restricts
> the spender as an operator distinct from the owner** (e.g. `RuleSpenderAuthorized`). If
> the enforcement path still applies such a rule when `spender == from`, the short-circuit
> converts a *code-mismatch* into a worse *report-OK-but-revert* divergence. This tension —
> and the fact that the two extension MUSTs (`spender == from` equality vs. `From`-variant
> enforcement consistency) can become mutually unsatisfiable — is analysed in
> [§8](#8-security-analysis--delegating-transferfrom-evaluation-to-the-non-spender-aware-path).
> Apply the short-circuit **only** together with the enforcement guarantee described there.

**Add a test** asserting, over fuzzed `(from, to, value)` and relevant frozen/rule
states, that `detectTransferRestrictionFrom(x, x, y, v) == detectTransferRestriction(x, y, v)`.

---

## 5. Other observations (informational)

- **Additional restriction codes for supply-changing ops.** The spec explicitly
  permits analogous checks on mint/burn (§Additional Specifications). CMTAT applies them
  via `_checkTransferred` on the mint/burn paths (`0_CMTATBaseCommon.sol:128,138`).
  Conformant and optional. The `spender` of a mint/burn is not currently threaded into a
  `detectTransferRestrictionFrom`-style predictor; the spec says that is a MAY, so no
  action required.
- **Interface not inheriting `IERC20`.** `draft-IERC1404.sol:6-9` documents the
  deliberate deviation from the original ERC-1404 (which extended `IERC20`). This is
  fully aligned with the rework's token-agnostic framing (§Rationale item 4 / §Additional
  Specifications: a compliance contract may implement the restriction interface without a
  token interface). The concrete CMTAT token still implements ERC-20 via
  `ERC20Upgradeable`, so the "MUST implement its underlying token interface" clause holds
  at the token level.
- **Determinism.** Every predicate reads issuer-controlled contract state (frozen flags,
  pause/deactivate flags, frozen-token balances) — no counterparty-manipulable inputs
  (§Security Considerations, flash-loan guidance) — so the determinism SHOULD is met.
- **`value` unused in the base predicate.** `_detectTransferRestriction`
  (`ValidationModuleERC1404.sol:142`) ignores `value`; the value-dependent check
  (active balance) is correctly layered in the `4_` override (`:98`). Intentional and
  fine.

---

## 6. Suggestions

### 6.1 Implementation
1. **Fix the `spender == from` short-circuit** (§4) and add the equivalence fuzz test.
2. **Encode the detect/enforce equivalence as a tested invariant** (the spec's
   Security-Considerations SHOULD): a fuzz test asserting `detectTransferRestriction(...) != 0`
   **iff** `transfer(...)` reverts, and likewise for the `From`/`transferFrom` pair.
   Because CMTAT uses the "re-evaluate" enforcement strategy, this is the exact drift the
   spec warns about; a property test locks it down.
3. **Make the `deactivated`/`paused` coupling explicit** (§2 note): either check
   `deactivated` in the standard-transfer enforcement path too, or add an assertion/comment
   at the enforcement site referencing the `deactivated ⇒ paused` invariant, so a future
   change to `unpause`/`deactivate` can't silently desynchronise reporting from enforcement.
4. **Restriction-code namespacing.** CMTAT reserves `0–6` (`draft-IERC1404.sol:49-57`)
   and the rework leaves `7–12` free; rule mocks use `21`. Document the reserved ranges in
   one place so composed rule engines don't collide within the 256-value `uint8` space.

### 6.2 The standard itself
1. **Relax or clarify the `spender == from` MUST.** The current text requires *code
   equality* for the degenerate case, which conflicts with the very natural design of
   emitting a distinct "spender frozen" reason: an implementation that reports
   `SPENDER_FROZEN` when a frozen holder self-initiates a `transferFrom` is arguably more
   informative, yet non-conformant. Consider one of:
   - weaken the MUST to *reject/allow equivalence* (`== 0` iff base `== 0`) for
     `spender == from`, keeping the exact code an implementation detail; **or**
   - keep code-equality but add explicit guidance that spender-specific codes MUST NOT be
     produced when `spender == from` (i.e. mandate the short-circuit of §4), and show it in
     the Reference Implementation.
   The CMTAT case is a concrete data point that the current wording is easy to violate.
2. **Guidance for delegating implementations.** Many real tokens (CMTAT included) delegate
   `detectTransferRestrictionFrom` to a sub-policy/rule engine. The spec could add a
   non-normative note: to guarantee the `spender == from` MUST irrespective of the
   sub-policy, resolve the degenerate case at the token layer by calling
   `detectTransferRestriction`, rather than passing `spender == from` down to a policy that
   may treat the spender dimension independently.
3. **Distinguishable "unknown code" contract for `messageForTransferRestriction`.** The
   spec leaves the return for an unrecognised code unspecified; CMTAT returns `"UnknownCode"`.
   A one-line SHOULD ("for an unallocated code, implementations SHOULD return a message
   distinguishable from any valid restriction message") would help UI builders.
4. **Reserved-range convention.** Given the `uint8` space and the composition pattern
   (token-native codes + rule-engine codes), the standard could suggest a lightweight
   namespacing convention (e.g. issuer reserves a low range, policies use a high range) to
   reduce collision risk it already flags in Security Considerations.

---

## 7. Summary table

| Requirement | Status |
|-------------|--------|
| `detectTransferRestriction` present, returns `uint8`, `0` = OK | ✅ |
| `messageForTransferRestriction` present, deterministic | ✅ |
| Enforcement consistent with base method (reject iff non-zero) | ✅ (via re-evaluate strategy) |
| ERC-165 `0xab84a5c8` advertised | ✅ (verified) |
| Extension `detectTransferRestrictionFrom` present | ✅ |
| ERC-165 `0x78a8de7d` advertised, computed by explicit XOR (not `type().interfaceId`) | ✅ (verified) |
| Delegated enforcement consistent with `detectTransferRestrictionFrom` | ✅ |
| `spender == from` ⇒ same code as `detectTransferRestriction` | ❌ **Low-severity MUST violation (§4)** |
| Optional mint/burn restriction checks | ✅ (optional) |
| Determinism / no manipulable inputs | ✅ |

---

## 8. Security analysis — delegating `transferFrom` evaluation to the non-spender-aware path

A delegated transfer (`transferFrom`, executed by a `spender` that may differ from `from`)
can end up evaluated by the **three-argument, non-spender-aware** predictor
`detectTransferRestriction(from, to, value)` instead of the four-argument
`detectTransferRestrictionFrom(spender, from, to, value)`. This happens in two places:

- **(P1) The `spender == from` short-circuit** recommended in [§4](#4-finding--spender--from-code-equality-must-violation--severity-low): the token resolves the degenerate delegated transfer by calling the non-spender-aware method.
- **(P2) Integrators / integrating contracts** that gate or predict a `transferFrom` by calling the base `detectTransferRestriction` (or `canTransfer`) rather than the spender-aware companion.

Below is the threat model for both. **None of these is an on-chain enforcement bypass in
CMTAT** — the transfer path itself stays spender-aware (`transferFrom` →
`_checkTransferred(msg.sender, …)` → `_canTransferisFrozenAndRevert(spender,…)` +
`ruleEngine.transferred(spender,…)`, `ValidationModule.sol:143`,
`ValidationModuleRuleEngine.sol:142`) and remains authoritative. The risks are
**mis-prediction, standards non-conformance, and the downstream DoS / UX / integration
failures they cause.**

### 8.1 Threats

**T1 — Optimistic mis-prediction → silent DoS (applies to P1 and P2).**
The non-spender-aware method cannot observe a spender-specific restriction (frozen operator,
operator not on an allow-list, per-operator limits). It therefore returns `0` ("no
restriction") for a `transferFrom` that the on-chain path then **reverts**. Consumers that
trust the `0` — exchanges pre-flighting withdrawals, batchers, relayers, aggregators —
submit transactions that fail, wasting gas and, in batched/atomic contexts, reverting
unrelated operations. The spec calls this out directly (Security Considerations: *"Integrators
MUST NOT treat a 0 from `detectTransferRestriction` as a prediction that a `transferFrom`
will succeed"*).

**T2 — The short-circuit can invert the divergence into report-OK-but-revert (P1).**
The [§4](#4-finding--spender--from-code-equality-must-violation--severity-low) fix makes
`detectTransferRestrictionFrom(from, from, to, v)` return
`detectTransferRestriction(from, to, v)`, which for a *valid holder* is `0`. But CMTAT's
enforcement of that same self-initiated `transferFrom` calls
`ruleEngine.transferred(from, from, to, v)` (the **4-arg**, spender-aware hook). If any rule
restricts `from` **as an operator** (as `RuleSpenderAuthorized` does: only a designated
custodian may initiate a delegated transfer, `RuleSpenderAuthorized.sol:37-47`), enforcement
**reverts** while the predictor now reports `0`. This is strictly worse than the original
code-mismatch: a `0` that precedes a revert is exactly the machine-readable-code failure the
standard exists to prevent, and it violates the **`From`-variant enforcement-consistency
MUST** ("MUST NOT be rejected for restriction reasons when `detectTransferRestrictionFrom`
returns `0`").

**T3 — Two extension MUSTs become mutually unsatisfiable under an owner-as-operator policy.**
For a policy that (a) permits `from` to move its own tokens by a direct `transfer` yet (b)
forbids `from` from acting as its own `transferFrom` operator, the extension's two MUSTs
collide:
- *Equality MUST* wants `detectTransferRestrictionFrom(from, from, …) == detectTransferRestriction(from, …) == 0`.
- *`From`-consistency MUST* wants `detectTransferRestrictionFrom(from, from, …) != 0`, because the actual self-`transferFrom` reverts.
No implementation can satisfy both. The existence of such a policy is therefore the real
design decision hiding behind the §4 finding — not a code detail.

**T4 — False authorization assumption in integrating contracts (P2).**
A contract that treats `canTransfer(from, to, value) == true` as evidence that a *specific
spender* is authorized (then performing privileged bookkeeping, credit, or accounting on that
basis) is reasoning about a predicate that never looked at the spender. In CMTAT the token
transfer still reverts on a frozen/unauthorized spender, so no tokens move — but the
integrator's own state may already have advanced. This is an integration bug, but the
non-spender-aware surface makes it easy to write.

### 8.2 Why CMTAT core is safe, and where the risk actually lives

The CMTAT **core** dimensions are safe under the short-circuit because they key on the
*address*, not on an operator role distinct from ownership:
- **Freeze / pause / deactivate / active-balance** — when `spender == from`, freezing `from`
  and freezing `from`-as-spender are the same fact, so the non-spender-aware result and the
  enforced result agree. `transfer` deliberately passes `spender == address(0)`
  (`0_CMTATBaseCommon.sol:75`), so direct transfers are correctly evaluated by the 3-arg hook
  with no operator dimension to lose.

The risk surfaces **only** once a **RuleEngine rule distinguishes the operator identity from
the owner identity** (allow-listed operators, frozen operators, per-operator caps). That is
precisely the class `RuleSpenderAuthorized` represents, and precisely where P1's short-circuit
and P2's mis-prediction bite.

### 8.3 Recommendations

1. **Decide the owner-as-operator semantics explicitly — it is a policy choice, not a code
   detail.** Answer: *may a token holder always initiate a `transferFrom` of their own tokens
   (subject to the normal `from`/`to`/`value` checks and their own allowance)?*
   - **If yes** (the spec's assumed model — "a direct transfer is the degenerate delegated
     transfer whose initiator is the holder"): adopt the §4 short-circuit **and** make the
     enforcement path exempt `spender == from` from operator-only rules — e.g. have every
     spender-restricting rule early-return `TRANSFER_OK` when `spender == from`
     (`RuleSpenderAuthorized`: add `|| spender == from`). Only with *both* sides exempting the
     degenerate case do the equality MUST and the `From`-consistency MUST hold simultaneously.
     **Do not ship the reporting-side short-circuit alone** (that is T2).
   - **If no** (operator must be a designated custodian even for self-initiated delegated
     transfers): **do not** short-circuit; keep `detectTransferRestrictionFrom` fully
     spender-aware so it stays consistent with enforcement, accept that the *equality MUST* is
     violated for `spender == from`, and pursue the spec relaxation in
     [§6.2](#62-the-standard-itself) (weaken equality to reject/allow equivalence).

2. **Make the choice a tested invariant — assert both MUSTs together.** A single equality
   test is insufficient because it hides T2. Fuzz over `(spender, from, to, value)` and rule
   state and assert **both**:
   - `detectTransferRestrictionFrom(x, x, y, v) == detectTransferRestriction(x, y, v)` (equality), **and**
   - `detectTransferRestrictionFrom(s, f, t, v) == 0` **iff** `transferFrom(f, t, v)` by `s` succeeds (`From`-consistency).
   If a policy makes these two assertions contradict, the suite fails — which is the correct,
   loud signal that the owner-as-operator semantics of recommendation 1 must be settled before
   shipping.

3. **Integrator guidance (P2 / T1 / T4).** To predict or gate a `transferFrom`, integrators
   MUST use `detectTransferRestrictionFrom` / `canTransferFrom`, never the 3-arg method.
   CMTAT should keep advertising the extension via ERC-165 (`0x78a8de7d`,
   `4_CMTATBaseERC1404.sol:80`) so integrators can *discover* the spender-aware predictor with
   one `supportsInterface` call; a token that does not expose the extension cannot predict
   `transferFrom` on-chain and integrators must fall back to submitting and handling the
   revert. `canTransfer`/`detectTransferRestriction` must never be treated as spender
   authorization.

4. **Never widen `transfer` to the 4-arg operator rules, and never narrow `transferFrom` away
   from them.** The token's routing (`transfer` → 3-arg `transferred`, `transferFrom` → 4-arg
   `transferred`, `ValidationModuleRuleEngine.sol:142`) is attacker-independent and correct;
   it must stay that way so operator rules cannot be bypassed by disguising a delegated
   transfer as a direct one, nor spuriously applied to genuine direct transfers.
