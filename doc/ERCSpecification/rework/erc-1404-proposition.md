# Proposition — ERC-1404 rework: relax the `spender == from` equality requirement

**Target document:** [`erc-1404.md`](./erc-1404.md) (rework draft, spender-aware extension)
**Related analyses:** [`erc-1404-analysis-rework.md`](./erc-1404-analysis-rework.md) §4 / §8,
[`ruleengine-erc1404-rework.md`](./ruleengine-erc1404-rework.md) §4.2
**Status:** proposal for discussion
**Type:** editorial + normative change to the OPTIONAL extension section only (no interface-id change)

---

## 1. Summary

The current extension text requires, as a **MUST**, that when `spender == from` the
spender-aware predictor return the *same code* as the base predictor:

> MUST, when `spender == from`, return the same code as `detectTransferRestriction(from, to, value)`,
> since a direct transfer is the degenerate delegated transfer whose initiator is the holder.

This proposition **removes that unconditional equality MUST** and replaces it with:

- keep the fundamental **enforcement-consistency MUST** for every spender, `spender == from` included;
- **SHOULD** evaluate `spender == from` through the spender-aware path (treat `transferFrom` as a
  delegated transfer regardless of whether the initiator happens to equal `from`);
- **MAY** skip the spender-specific checks for `spender == from` **as an optimization**, but only
  where that skip is observably equivalent (the policy imposes no operator-identity restriction
  beyond ownership).

Net effect: an implementation that keeps `transferFrom` on the spender-aware path even when
`spender == from` (as CMTAT does) becomes **conformant as written**, and the accidental
report-OK-but-revert trap the equality MUST can create is eliminated.

---

## 2. Motivation

### 2.0 Worked counterexample — whitelisted-spender policy

Consider a policy where **every `transferFrom` spender must be whitelisted**, while a direct
`transfer` is unrestricted. Take an address `A` that is **not** a whitelisted spender:

| Call | Correct result | Reason |
|------|----------------|--------|
| `transfer(to, v)` by `A` | succeeds | direct transfers are unrestricted |
| `detectTransferRestriction(A, to, v)` | `0` | reports that `A`'s direct transfer is allowed |
| `transferFrom(A, to, v)` by `A` | **reverts** | `A` is not a whitelisted spender — even of its own tokens |
| `detectTransferRestrictionFrom(A, A, to, v)` | **non-zero** | must faithfully report the delegated transfer it describes |

The current equality MUST forces `detectTransferRestrictionFrom(A, A, to, v)` to return `0` (to
match `detectTransferRestriction`). That is not merely over-specified — it is **wrong**: it
predicts success for a `transferFrom` that reverts, and it directly contradicts the
enforcement-consistency MUST in the same section. A policy is entitled to allow an address to
`transfer` but forbid it from acting as a `transferFrom` operator, and the spender-aware
predictor must be free to say so.

### 2.1 `transferFrom` is a distinct operation

**`transferFrom` with `spender == from` is not the same operation as `transfer`.** They are
distinct entry points with distinct authorization machinery. Even mechanically, OpenZeppelin's
`transferFrom` runs `_spendAllowance(from, from, value)` (`ERC20Upgradeable.sol:165,319`) and
flows through the allowance path, which `transfer` never touches. The premise behind the
equality MUST — "a direct transfer *is* the degenerate delegated transfer whose initiator is
the holder" — therefore does not hold at the EVM level. A policy is entitled to distinguish
"holder moves own tokens directly" from "a delegated-transfer operator, who happens to be the
holder, moves tokens" (e.g. a compliance regime where any `transferFrom` operator must be a
licensed custodian).

**Enforcement-consistency is the property integrators actually need — equality can contradict it.**
The spender-aware predictor exists so a caller can predict a *delegated* transfer. Requiring
`detectTransferRestrictionFrom(from, from, …)` to mirror the *direct-transfer* predictor forces
it to misreport the delegated transfer it is describing. Worse, for a policy that restricts the
operator identity, the equality MUST and the enforcement-consistency MUST become **mutually
unsatisfiable**:

| | wants |
|---|---|
| equality MUST | `detectTransferRestrictionFrom(from, from, …) == detectTransferRestriction(from, …) == 0` |
| enforcement-consistency MUST | `detectTransferRestrictionFrom(from, from, …) != 0`, because the self-`transferFrom` reverts |

When a derived MUST cannot coexist with the fundamental consistency MUST, the derived one must
give. This proposition resolves the conflict in favour of consistency.

**What the equality clause was buying is preserved elsewhere.** Its useful effect — preventing a
self-`transferFrom` from silently skipping the `from`/`to`/`value` checks — is already guaranteed
by the extension's third bullet ("the base method continues to describe the `from`/`to`/`value`
conditions; the extension adds only the `spender` dimension"). The extension is a *superset* of
the base conditions, not a replacement, so dropping equality does not reintroduce that footgun.

**The optimization the equality clause forbids is legitimate and should be explicitly allowed.**
For the common whitelist/freeze-style policies that do *not* single out operator identity,
evaluating `spender == from` through the cheaper non-spender-aware path yields an identical
result. Implementations should be free to take that gas saving — but as a MAY conditioned on
equivalence, not as a blanket MUST that also traps operator-restricting policies.

---

## 3. Proposed specification changes

### 3.1 Extension section — the three bullets

**Current** (§ *Extension: spender-aware restriction detection*):

> An implementation that exposes `detectTransferRestrictionFrom`:
>
> - MUST keep it consistent with delegated-transfer enforcement, in the same sense the base
>   method is consistent with the transfer path: a `transferFrom(from, to, value)` executed by
>   `spender` MUST be rejected whenever `detectTransferRestrictionFrom(spender, from, to, value)`
>   would return a non-zero code, and MUST NOT be rejected for restriction reasons when it would
>   return `0`.
> - **MUST, when `spender == from`, return the same code as `detectTransferRestriction(from, to, value)`,
>   since a direct transfer is the degenerate delegated transfer whose initiator is the holder.**
> - MUST NOT change the meaning of, or the enforcement consistency required of,
>   `detectTransferRestriction`. …

**Proposed** (replace the middle bullet; the first and third are unchanged):

> An implementation that exposes `detectTransferRestrictionFrom`:
>
> - MUST keep it consistent with delegated-transfer enforcement … *(unchanged)*
> - **SHOULD evaluate the `spender == from` case through the spender-aware path, because
>   `transferFrom` is a distinct delegated-transfer entry point whose authorization may depend on
>   the initiating operator even when that operator equals `from`. An implementation MAY instead
>   evaluate `spender == from` through the non-spender-aware path — equivalently, skip the
>   spender-specific checks — as an optimization, but only when doing so is observably equivalent,
>   i.e. its policy imposes no restriction on the initiating operator's identity beyond the
>   `from`/`to`/`value` conditions. An implementation whose policy *does* restrict the operator
>   identity (for example, an allow-listed or frozen operator set) MUST NOT skip, since skipping
>   could return `0` (or an owner-only code) for a self-initiated `transferFrom` that enforcement
>   rejects, violating the enforcement-consistency requirement above. When the policy does not
>   distinguish operator identity from ownership, `detectTransferRestrictionFrom(from, from, to, value)`
>   and `detectTransferRestriction(from, to, value)` return the same code, and skipping is always
>   safe.**
> - MUST NOT change the meaning of, or the enforcement consistency required of,
>   `detectTransferRestriction`. … *(unchanged)*

### 3.2 Rationale — item 5

**Add** to Rationale item 5 (*Optional spender-aware detection*):

> The extension does not require `detectTransferRestrictionFrom(from, from, …)` to equal
> `detectTransferRestriction(from, …)`. A `transferFrom` initiated by the holder is still a
> delegated transfer — it flows through the allowance path and is a different entry point than a
> direct `transfer` — so a policy that restricts the initiating operator (even when the operator
> is the holder) is legitimate, and the spender-aware predictor must be free to describe it. The
> only invariant that matters for integrators is that `detectTransferRestrictionFrom` agree with
> `transferFrom` enforcement; requiring it to instead mirror the direct-transfer predictor would
> force it to misreport, and for operator-restricting policies would conflict with that agreement.
> Implementations whose policy does not distinguish operator identity from ownership will observe
> the two predictors coincide for `spender == from` and MAY skip the spender-aware evaluation as
> an optimization.

### 3.3 Test Cases — `detectTransferRestrictionFrom` table

**Current** row:

| Scenario | Expected return |
|---|---|
| `spender == from` | Equal to `detectTransferRestriction(from, to, value)` |

**Proposed** rows:

| Scenario | Expected return |
|---|---|
| `spender == from`, policy does **not** restrict operator identity | Equal to `detectTransferRestriction(from, to, value)` |
| `spender == from`, policy **does** restrict the initiating operator | Reflects the delegated-transfer policy for that operator, and is consistent with `transferFrom` enforcement; MAY differ from `detectTransferRestriction(from, to, value)` |

(The existing "consistent with `transferFrom` enforcement" rows already cover the binding
requirement; these two rows replace the single equality row.)

### 3.4 Security Considerations — the `spender == from` note

**Add** a bullet:

> Because `transferFrom` is a delegated-transfer entry point, an implementation that restricts the
> initiating operator SHOULD evaluate `spender == from` through the spender-aware path rather than
> collapsing it to the direct-transfer predictor. Collapsing it (for example, an unconditional
> `if (spender == from) return detectTransferRestriction(from, to, value);` short-circuit) can make
> `detectTransferRestrictionFrom` return `0` for a self-initiated `transferFrom` that enforcement
> then rejects, reintroducing a reporting/enforcement divergence. The non-spender-aware evaluation
> is a safe optimization *only* for policies that do not restrict operator identity beyond ownership.

---

## 4. Backwards compatibility

- **No interface-identifier change.** The mandatory id `0xab84a5c8` and the extension id
  `0x78a8de7d` are unaffected; method signatures are unchanged.
- **Strictly more permissive.** Any implementation that satisfied the old equality MUST still
  conforms (its policy simply does not restrict operator identity, so the two predictors coincide
  and the optimization applies trivially). No previously-conformant implementation becomes
  non-conformant.
- **Newly-conformant implementations.** Implementations that keep `transferFrom` on the
  spender-aware path for `spender == from` — CMTAT and any operator-restricting policy — become
  conformant without a code change.

---

## 5. Impact on the CMTAT analyses

Adopting this proposition reclassifies the prior findings:

- `erc-1404-analysis-rework.md` §4: from an **implementation MUST violation** to
  **conformant as written**. The recommended `spender == from` short-circuit is **withdrawn** — it
  is the report-OK-but-revert hazard described in §8 (T2) and §3.4 above.
- `ruleengine-erc1404-rework.md` §4.2: `RuleSpenderAuthorized` rejecting a self-initiated
  `transferFrom` is **intended behaviour** under an operator-restricting policy, not a defect.
- The corresponding rows of both summary tables move from ❌ to ✅.

These reclassifications should be applied to the analysis documents once this proposition is
accepted, with a short note preserving the reasoning trail.
