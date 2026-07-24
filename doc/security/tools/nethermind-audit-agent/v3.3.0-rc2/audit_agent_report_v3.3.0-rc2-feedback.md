# CMTAT Maintainer Feedback — Nethermind AuditAgent v3.3.0-rc2

Date: 2026-07-24
Source report: [audit_agent_report_v3.3.0-rc2.pdf](./audit_agent_report_v3.3.0-rc2.pdf)

## Tool

[**Nethermind AuditAgent**](https://auditagent.nethermind.io/) — an AI-powered automated code-scanning tool.

> **This scan was performed by an AI-powered automated tool, not a formal human-led audit.**
> The report carries Nethermind's own *Important Notice*: it "has been generated entirely by AI and has not been
> manually reviewed by Nethermind's security team. It does not constitute a full security audit … All findings,
> observations, and recommendations may contain errors or omissions and must be independently verified by a
> qualified human reviewer before being acted upon."
> Per Nethermind's terms, this run **must not** be represented as "audited by Nethermind".
> This file is that independent verification: every finding below was re-read against the actual source.

## Scan metadata

| Field | Value |
| --- | --- |
| Scan ID | 9 |
| Date | July 23, 2026 |
| Organization | CMTA |
| Repository | CMTAT |
| Branch | `master` |
| Commit hash | `35d8940b…9d92e4ae` |
| Contracts scanned | 100 |
| Lines of code | 8067 |
| Findings | 24 |

Scope covered the full production surface: all `contracts/deployment/*` variants (Standard, UUPS, Allowlist,
Debt, DebtEngine, HolderList, Permit, Snapshot, ERC-1363, ERC-7551, Light), `contracts/modules/*` (base levels
0–8, `internal/`, `wrapper/{core,extensions,options,controllers,security}`), `contracts/interfaces/*` and
`contracts/library/*`.

> **Commit note.** The scanned commit `35d8940b…` is not present in this working tree (local `HEAD` is
> `7316f96` on `dev`; `VersionModule.VERSION == "3.3.0"`). Verification below was performed against the current
> v3.3.0 source. Every cited code path was located and matches the report's excerpts, so the delta between the
> scanned commit and the verified tree does not affect any disposition.

## Report snapshot (tool-reported counts)

- High Risk: **1**
- Medium Risk: **4**
- Low Risk: **3**
- Info: **14**
- Best Practices: **2**
- **Total: 24**

## Outcome

**5 fixed · 14 accepted as design · 4 rejected (false positive / false premise) · 1 fix recommended** = 24.

Three defects were fixed: **NM-15/NM-17** (zero-address freeze bricking every mint path), **NM-3/NM-8** (allowance
revocation blocked while paused or restricted) and **NM-22** (ERC-7551 `setTerms` erasing the document name).
NM-6 was additionally **documented** rather than changed. The one remaining "fix recommended" item (NM-24) is a
NatSpec correction. None of the 24 findings is exploitable by an unprivileged actor.

## Findings triage

| ID | Severity (tool → ours) | Disposition | Status |
| --- | --- | --- | --- |
| NM-1 | High → Informational | Rejected (false positive) | Closed |
| NM-2 | Medium → Informational | Rejected (duplicate of NM-1) | Closed |
| NM-3 | Medium → Low | **Fixed** | **Fixed** — revocation (`value == 0`) always authorized |
| NM-4 | Medium → Informational | Rejected (design; misconfiguration precondition) — **documented** | Closed — deployment constraint documented |
| NM-5 | Medium → Informational | Accepted as design — spender propagation traced and probed | Accepted (see follow-up on `access-control.md`) |
| NM-6 | Low → Informational | Accepted as design (RuleEngine responsibility) — **documented** | Accepted — doc + NatSpec added |
| NM-7 | Low → Low | Accepted as design (trusted-RuleEngine model) | Accepted |
| NM-8 | Low → Low | **Fixed (same change as NM-3)** | **Fixed** |
| NM-9 | Info → Low | Accepted as design (duplicate of NM-7) | Accepted |
| NM-10 | Info → Informational | Rejected (false premise) | Closed |
| NM-11 | Info → Low | Accepted as design (duplicate of NM-7) | Accepted |
| NM-12 | Info → Informational | Accepted as design | Accepted |
| NM-13 | Info → Informational | Accepted as design | Accepted |
| NM-14 | Info → Informational | Accepted as design | Accepted |
| **NM-15** | **Info → Low** | **Fixed** | **Fixed** — zero-address guard in `_setFrozenTokens` |
| NM-16 | Info → Low | Accepted as design (duplicate of NM-7) | Accepted |
| **NM-17** | **Info → Low** | **Fixed (same defect as NM-15)** | **Fixed** |
| NM-18 | Info → Informational | Accepted as design (duplicate of NM-7) | Accepted |
| NM-19 | Info → Informational | Accepted as design | Accepted |
| NM-20 | Info → Informational | Accepted as design | Accepted |
| NM-21 | Info → Informational | Accepted as design (claim overstated) — **documented** | Accepted — doc + NatSpec added |
| **NM-22** | **Info → Informational** | **Fixed** | **Fixed** — ERC-7551 overload preserves the name |
| NM-23 | Best Practices → Informational | Accepted as design (optional reorder) | Accepted |
| **NM-24** | **Best Practices → Informational** | **Fix recommended (NatSpec)** | **Open** |

---

## Detailed assessment

### NM-1 — Uninitialized proxy can be seized by the first caller to `initialize` (High → Informational)

**Claim.** `initialize(...)` is `public` and guarded only by OpenZeppelin's `initializer` modifier, so on a fresh
proxy any account can win the first call, obtain `DEFAULT_ADMIN_ROLE`, and — because `hasRole` treats the default
admin as holding every role — take over the token.

**Verdict — rejected (false positive).** Every implementation contract disables initialization in its
constructor (`_disableInitializers()`; e.g. `contracts/deployment/allowlist/CMTATUpgradeableAllowlist.sol:19`,
`contracts/deployment/CMTATStandardUpgradeable.sol`, `contracts/deployment/CMTATUpgradeableUUPS.sol`), so the
implementation itself cannot be claimed. For the proxy, the deployment contract must be created and initialized
**in the same transaction** — the standard OpenZeppelin proxy-deployment requirement, satisfied by
`ERC1967Proxy`/`TransparentUpgradeableProxy` constructor calldata and by the CMTAT deployment tooling. The
report concedes the precondition itself: *"The deployment process can deploy a Transparent or Beacon proxy
without constructor/deployment calldata that atomically invokes `initialize`; this is not demonstrated by the
supplied deployment scripts."* Same disposition as AuditAgent v3.1.0 finding #2 (Invalid).

*Action taken:* none in code. The atomic-initialization requirement is a deployment-integration property; see the
deployment documentation.

### NM-2 — Anyone can claim an uninitialized proxy by calling `initialize` first (Medium → Informational)

**Claim.** Same as NM-1, cited on `contracts/modules/0_CMTATBaseCore.sol`.

**Verdict — rejected (duplicate of NM-1).** The report even notes the implementation is protected by
`_disableInitializers()` and that the assessment "assumes deployments can actually leave a proxy uninitialized".

### NM-3 — Paused or restricted holders cannot revoke stale allowances (Medium → Low — **FIXED**)

**Claim.** `_canAuthorizeAllowanceByModuleAndRevert(owner, spender)` does not receive `value`, so
`approve(spender, 0)` is rejected under the same conditions as a new grant: while paused, while either party is
frozen, or (Allowlist variant) while either party is off the allowlist. A holder therefore cannot use the
zero-first mitigation during a restriction window, and a compromised spender can back-run the restoration.

**Verdict — VALID. Fixed.** The behaviour was real:
`contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleAllowance.sol` calls `_requireNotPaused()`
and `_canSend(owner)` / `_canSend(spender)` unconditionally, and `approve` carries `whenNotPaused` in
`3_CMTATBaseRuleEngine.sol` / `3_CMTATBaseAllowlist.sol`. This is the direct consequence of the fix CMTA applied
in v3.2.0 to the previous AuditAgent finding #13 (*"approve not protected by pause"*) — the two requests point in
opposite directions, and CMTA chose "pause freezes the whole allowance surface".

The residual exposure is narrow — while the restriction holds, `transferFrom` is blocked by the same gates, so no
allowance can be consumed, and the only window is the instant of restoration. CMTA nonetheless decided to close
it: a holder must always be able to sever ties with a compromised or sanctioned spender.

**Resolution — fixed.**

- **Confirmation before fixing.** Six tests were added first and the four revocation cases confirmed **failing**
  on the unfixed code (`approve(spender, 0)` reverted with `EnforcedPause` / `ERC7943CannotSend`), while the two
  "must stay blocked" cases already passed.
- **Fix.** `_canAuthorizeAllowanceByModuleAndRevert` now takes the allowance `value` and returns early when it is
  zero:
  - `contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleAllowance.sol` — signature becomes
    `(address owner, address spender, uint256 value)`, with `if (value == 0) { return; }` before the
    pause/`canSend` checks. Setting an allowance to zero is a **revocation**: it can only reduce what a spender
    may move, so it is always authorized.
  - Call sites updated to pass `value`: `0_CMTATBaseCore.sol` (`approve`), `3_CMTATBaseRuleEngine.sol`
    (`approve`), `3_CMTATBaseAllowlist.sol` (`approve`), `6_CMTATBaseERC2612.sol` (`permit` — a gasless
    revocation must work for the same reason).
  - The redundant `whenNotPaused` modifier was removed from the `approve` overrides in `3_CMTATBaseRuleEngine.sol`
    and `3_CMTATBaseAllowlist.sol`. It would have rejected the revocation before the internal check ran; the pause
    enforcement it provided is unchanged, because `_canAuthorizeAllowanceByModuleAndRevert` already calls
    `_requireNotPaused()` for every non-zero value.
- **Non-zero grants are unaffected.** While paused, or when the owner/spender is frozen or off the allowlist,
  `approve(spender, n > 0)` and `permit` with a non-zero value still revert exactly as before — covered by the two
  negative tests below and by the pre-existing
  `testCannotApproveWhenOwnerIsNotAllowlisted` / `testCannotApproveWhenSpenderIsNotAllowlisted`.
- **Tests.**
  - `test/common/PauseModuleCommon.js` — `testCanRevokeAllowanceWhenPaused`,
    `testCanRevokeAllowanceWhenDeactivated`, `testCannotGrantAllowanceWhenPaused` (negative guard).
  - `test/common/EnforcementModuleCommon.js` — `testCanRevokeAllowanceWhenSpenderIsFrozen`,
    `testCanRevokeAllowanceWhenOwnerIsFrozen`, `testCannotGrantAllowanceWhenSpenderIsFrozen` (negative guard).
  - `test/common/AllowlistModuleCommon.js` — `testCanRevokeAllowanceWhenSpenderIsNotAllowlisted`.
- **Verification.** The four revocation tests went from failing to passing on the fix; the two negative guards
  passed throughout. Both fixes were validated together against the whole test suite: **5866 passing, 87 pending,
  0 failing**.
- **Note for integrators.** This reverses the v3.2.0 response to AuditAgent v3.1.0 finding #13 *for the zero value
  only*. `approve` remains pause-gated for every non-zero amount; only revocation was opened. The `whenNotPaused`
  modifier no longer appears on the `approve` signatures, but the pause enforcement it provided is unchanged.

### NM-4 — Inconsistent context resolution allows role spoofing and unlimited minting (Medium → Informational)

**Claim.** `onlyTokenBridge` resolves the caller with raw `msg.sender` while every other role gate uses
`_msgSender()`. An administrator "fixing" a forwarder-relayed bridge by granting `CROSS_CHAIN_ROLE` to the trusted
forwarder would let any user meta-transact `crosschainMint` and mint arbitrarily. Separately, a compromised
forwarder can append any admin address and impersonate role holders.

**Verdict — rejected (intentional, and the precondition is an administrator doing what the code warns against).**
The `msg.sender` choice is deliberate and documented in-line at
`contracts/modules/wrapper/options/ERC20CrossChainModule.sol` (modifier `onlyTokenBridge`): *"Token bridge should
never be impersonated using a relayer/forwarder. Using `msg.sender` is preferable to `_msgSender()` for security
reasons."* This mirrors OpenZeppelin v5.4.0 `draft-ERC20Bridgeable.sol`. The described mint escalation requires
`CROSS_CHAIN_ROLE` to be granted to the ERC-2771 forwarder — precisely the configuration the comment forbids.

The second half restates the inherent ERC-2771 trust model: a trusted forwarder can, by construction, assert any
`_msgSender()`. This is already documented (`doc/technical/stablecoin.md:197` — *"the forwarder is fixed at
deployment. Verify that the chosen forwarder is trustworthy before deploying, as it can submit arbitrary calls on
behalf of any user"*), and the forwarder is immutable (constructor-set), so it cannot be swapped post-deployment.

**Resolution — documented (no behaviour change).** The disposition stands: `msg.sender` is the correct check and
the code was already right. What was missing is that the *deployment constraint* it implies was only discoverable
by reading a comment inside a modifier. It is now stated where an integrator will meet it:

- `doc/technical/cross-chain-bridge-integration.md` — new subsection *"The bridge gate uses `msg.sender`, not
  `_msgSender()`"* under the Access Control Summary. It gives the rationale (a bridge holds unbounded mint
  authority and must not be impersonable through a relayer), then the two practical consequences: a bridge must
  call `crosschainMint` / `crosschainBurn` **directly**, and `CROSS_CHAIN_ROLE` **must never** be granted to the
  ERC-2771 forwarder — spelling out that doing so would let any user mint arbitrarily through a relayed call, and
  that the forwarder is irrevocable in standalone deployments so the only remedy is revoking the role. It
  generalizes the rule: `CROSS_CHAIN_ROLE` must be held only by contracts whose call *is* the authorization
  decision.
- `doc/technical/access-control.md` — a Role Interaction Note recording that `CROSS_CHAIN_ROLE` is the only role
  gate checked against the raw `msg.sender`, with a link to the section above.
- `doc/modules/options/erc20crosschain/ERC20CrossChain.md` — the requirement lists for `crosschainMint` and
  `crosschainBurn` now state that the call cannot be relayed through the forwarder.
- `contracts/modules/wrapper/options/ERC20CrossChainModule.sol` — the `onlyTokenBridge` comment was extended with
  an explicit `DEPLOYMENT CONSTRAINT` paragraph. Comment-only; the bytecode is unchanged.

Note that the *first* consequence is the trap that leads to the second: an integrator whose relayed bridge call
reverts is being told, correctly, that the bridge must call directly — and the natural but catastrophic
"fix" is to grant the role to the forwarder. Documenting the revert without documenting why the obvious
workaround is unsafe would have left the finding's attack path open, which is why both are stated together.

### NM-5 — Missing freeze enforcement on `spender` for `burnFrom` and minter transfers (Medium → Informational)

**Claim.** Burn routing checks only `from`; `CMTATBaseCore._minterTransferOverride` hardcodes `address(0)` as the
spender; `CMTATBaseCommon._checkTransferred` ignores its `spender` argument entirely.

**Verdict — accepted as design.** All three observations are factually correct:

- `contracts/modules/0_CMTATBaseCore.sol` — `_minterTransferOverride` calls
  `ValidationModule._canTransferGenericByModuleAndRevert(address(0), from, to)`.
- `contracts/modules/0_CMTATBaseCommon.sol` — `_checkTransferred(address /*spender*/, …)` only calls
  `_checkActiveBalanceAndRevert(from, value)`; the spender-aware checks are layered by the derived modules
  (`3_CMTATBaseRuleEngine.sol`, `3_CMTATBaseAllowlist.sol`), which do pass `spender` through to
  `_canTransferGenericByModuleAndRevert`.
- `burnFrom` (`ERC20CrossChainModule`) routes to `_canBurnByModuleAndRevert(from)`, which checks the burn target,
  not the operator.

The rationale is unchanged from AuditAgent v3.1.0 findings #3 and #10: mint/burn/minter-transfer have **no
spender** in the ERC-20 sense — the actor is a `MINTER_ROLE` / `BURNER_ROLE` / `BURNER_FROM_ROLE` holder, and
account freezing is a *holder*-level control, not an operator-level one. The control for a compromised operator is
role revocation (`revokeRole`), which is immediate and total; freezing was never intended to demote a role holder.

#### What mint and burn actually pass as `spender`

Because the finding turns on this, the argument was traced end to end. The two hierarchies differ.

**`CMTATBaseCommon` (all full variants) — passes `_msgSender()`:**

| Path | Call | `spender` |
| --- | --- | --- |
| `_mintOverride` | `_checkTransferred(_msgSender(), address(0), account, value)` | the minter |
| `_burnOverride` | `_checkTransferred(_msgSender(), account, address(0), value)` | the burner |
| `_minterTransferOverride` | `_checkTransferred(_msgSender(), from, to, value)` | the minter |

**`CMTATBaseCore` (Light variants) — no spender at all:**

| Path | Call | `spender` |
| --- | --- | --- |
| `_mintOverride` | `_canMintByModuleAndRevert(account)` | n/a — not a spender-parameterized function |
| `_burnOverride` | `_canBurnByModuleAndRevert(account)` | n/a |
| `_minterTransferOverride` | `_canTransferGenericByModuleAndRevert(address(0), from, to)` | **hardcoded `address(0)`** |

So the report's specific claim about `CMTATBaseCore._minterTransferOverride` hardcoding `address(0)` is accurate,
but it applies to the **Light variants only**; the full variants propagate the real operator.

#### Where the spender goes after that

Propagating the operator is not the same as checking it. `ValidationModule._canTransferGenericByModuleAndRevert`
routes on `from`/`to`:

```solidity
if (from == address(0))      _canMintByModuleAndRevert(to);       // mint  -> spender DROPPED
else if (to == address(0))   _canBurnByModuleAndRevert(from);     // burn  -> spender DROPPED
else                         _canTransferStandardByModuleAndRevert(spender, from, to);  // spender USED
```

`_canMintByModuleAndRevert` and `_canBurnByModuleAndRevert` take a **single address** in every variant, including
the `ValidationModuleAllowlist` overrides. On mint and burn the spender is therefore carried all the way in and
then discarded at the routing step — the freeze check never sees it.

It is not discarded everywhere: in the RuleEngine variant, `ValidationModuleRuleEngine._transferred` branches on
`spender != address(0)`, so mint and burn reach the **4-argument** `ruleEngine_.transferred(spender, from, to,
value)` with the minter/burner as `spender`. The RuleEngine is told who the operator is; CMTAT's own freeze logic
does not use it.

#### Empirical confirmation

Probed on `CMTATStandardStandalone` (throwaway test, not retained):

| Scenario | Result |
| --- | --- |
| Frozen `MINTER_ROLE` holder calls `mint` | **Succeeds** — recipient balance 10 |
| Frozen `BURNER_ROLE` holder calls `burn` on a non-frozen holder | **Succeeds** — holder balance 100 → 90 |
| Burn targeting a frozen holder | Reverts `ERC7943CannotSend(holder)` ✓ |

Freezing an operator does not stop them minting or burning; freezing a holder does stop tokens being burned from
them. This matches the design rationale above, and confirms the disposition: the lever against a compromised
operator is `revokeRole`, not `setAddressFrozen`.

#### Follow-up: a documentation statement this contradicts

`doc/technical/access-control.md` currently states, under *Role Interaction Notes*:

> `ENFORCER_ROLE` can effectively block mint operations by freezing the minter/operator address with
> `setAddressFrozen(address, true)`. In spender-aware compliance paths, mint uses the effective operator as
> spender, so a frozen operator reverts with `ERC7943CannotSend`.

The probe contradicts this: the frozen minter minted successfully. The first half is right that the operator is
*passed* as `spender`, but the mint routing drops it before any freeze check, so no `ERC7943CannotSend` is raised.
The statement could only hold if a configured RuleEngine chose to reject the spender — which is not what the text
says, and is not true of the base contracts or of a deployment without a RuleEngine.

This is **not** part of NM-5 (the tool did not report it, and the contract behaviour is intended). It is tracked
here because it is a documented security control that does not exist as described — a reader could reasonably
freeze a compromised minter and believe issuance is stopped. Left unchanged pending a decision on whether to
correct the documentation or to make the behaviour match it.

### NM-6 — Zero-value delegated transfers can mutate RuleEngine state (Low → Informational)

**Claim.** OpenZeppelin's `_spendAllowance` treats `value == 0` as needing no allowance, so anyone can call
`transferFrom(victim, victim, 0)` and still trigger `ruleEngine.transferred(spender, from, to, 0)`, letting an
attacker poke stateful compliance accounting for arbitrary holders.

**Verdict — accepted as design; this is the RuleEngine's responsibility.** The path is real
(`0_CMTATBaseCommon.transferFrom` → `_checkTransferred` → `ValidationModuleRuleEngine._transferred` →
`ruleEngine_.transferred(...)`). But ERC-20 mandates that *"transfers of 0 values MUST be treated as normal
transfers"*, so suppressing the callback for `value == 0` would make the token's compliance notifications
inconsistent with its own transfer semantics. The report's own severity note lists the required precondition:
*"the RuleEngine does not independently reject zero-value events, self-transfers, or callbacks from an unapproved
spender."* A rule that meters quotas or cooldowns must be a no-op at `value == 0` — a requirement on the
`IRule`/`IRuleEngine` implementation, which is out of scope of this repository.

**Resolution — documented (no code change).** The requirement is now written down for RuleEngine implementers,
in the two places they actually read:

- `contracts/interfaces/engine/IRuleEngine.sol` — the NatSpec on the spender-aware
  `transferred(address spender, address from, address to, uint256 value)` now carries an explicit warning that
  zero-value calls are **permissionless** (any address can reach the callback for an arbitrary `from`, as
  `spender`, with no allowance, via `transferFrom(victim, anyone, 0)`), states why the token does not suppress
  them, and requires implementations to treat `value == 0` as carrying no economic meaning. It also notes that the
  3-argument ERC-3643 overload is reachable the same way through `transfer(to, 0)`.
- `doc/modules/controllers/validationRuleEngine.md` — a new *"Integration notes for RuleEngine implementers"*
  section explains the two ERC-20 properties that combine to allow it, gives the concrete call, and tabulates what
  a zero-value call must not do (cooldown timers, quotas, tax buckets, holder tracking, sanction bookkeeping). It
  also warns that rejecting zero-value calls outright (`require(value > 0)`) would make every zero-value transfer
  of the token revert, which is not ERC-20 compliant — a no-op is the recommended handling.

`IERC3643IComplianceContract.transferred` (the 3-argument overload) was intentionally left untouched: it is the
ERC-3643 standard interface definition, and CMTAT keeps those faithful to the specification. The zero-value
guidance for both overloads lives on CMTAT's own `IRuleEngine` instead.

### NM-7 / NM-9 / NM-11 / NM-16 / NM-18 — Reentrant RuleEngine callback before balance effects (Low ×1, Info ×4 → Low, one cluster)

**Claim (five reports of one structure).** In RuleEngine deployments the transfer path is
`_checkTransferred(...)` → `_checkActiveBalanceAndRevert(from, value)` (frozen-balance check) →
`ValidationModuleRuleEngine._transferred(...)` → **external** `ruleEngine_.transferred(...)` → and only then
`ERC20Upgradeable._transfer(...)`. Because the active-balance check runs before the external call and is never
re-evaluated after it, a RuleEngine that reenters `transferFrom` sees the same pre-transfer
`balanceOf`/`frozenTokens` snapshot in every frame; the final `_transfer` only validates *total* balance, so
stacked nested frames can move more than the unfrozen amount. Reported against `8_CMTATBaseERC1363.sol` (NM-7),
`0_CMTATBaseCommon.sol`/`3_CMTATBaseRuleEngine.sol` (NM-9), `5_CMTATBaseERC20CrossChain.sol` (NM-11),
`8_CMTATBaseHolderList.sol` (NM-16), and as a general checks-effects-interactions / read-only-reentrancy note
(NM-18).

**Verdict — accepted as design (trusted-RuleEngine model); ordering confirmed, exploitability requires an
untrusted engine.** The ordering is exactly as described — verified in
`contracts/modules/3_CMTATBaseRuleEngine.sol` (`_checkTransferred` calls `CMTATBaseCommon._checkTransferred` then
`ValidationModuleRuleEngine._transferred`) and in
`contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleRuleEngine.sol` (`_transferred` makes the
external call). The wrapper variants (ERC-1363, HolderList, CrossChain) inherit it unchanged, so the tool is right
that all of them share the ordering.

Exploitation requires the configured RuleEngine to reenter, or to call attacker-controlled code during
`transferred(...)`. The RuleEngine is set exclusively by `DEFAULT_ADMIN_ROLE` (`setRuleEngine`, see
`doc/modules/controllers/validationRuleEngine.md`) and is, by construction, a **fully trusted** component: it
already decides whether *any* transfer is permitted, and a malicious engine can block every transfer or
whitelist arbitrary ones without needing reentrancy. Rules called by the CMTA RuleEngine are likewise
admin-registered (`IRule`, [CMTA/Rules](https://github.com/CMTA/Rules)). With a rule set that does not call
untrusted code — the intended configuration — there is no reentrancy vector. This is consistent with the existing
Slither disposition for `reentrancy-events` on the document engine (design choice, admin-set trusted engine).

NM-18's read-only-reentrancy variant is the same precondition seen from outside: a third-party protocol reading
`balanceOf`/`totalSupply` *during* a RuleEngine callback observes pre-transfer state. That again requires the
trusted engine to hand control to untrusted code mid-callback.

*Two follow-ups for CMTA (neither is a fix to a live vulnerability):*
1. **Document the trust assumption.** `doc/modules/controllers/validationRuleEngine.md` currently describes the
   API but never states that the RuleEngine is fully trusted and **MUST NOT** transfer control to untrusted code
   during `transferred(...)`. That assumption is what makes this cluster non-exploitable, so it should be written
   down rather than implied.
2. **Optional defence in depth.** Either apply a `nonReentrant` guard to the ERC-20 entry points, or invoke the
   RuleEngine callback *after* `ERC20Upgradeable._transfer` (checks-effects-interactions). Both have costs — gas
   on every transfer for the guard, and a semantic change for the reordering (the engine would observe
   post-transfer state, and could no longer veto by reverting on pre-state) — so this is a deliberate design
   call, not a defect to be patched silently.

### NM-8 — Allowance revocation blocked for frozen or non-allowlisted spenders (Low → Low — **FIXED**)

**Verdict — VALID (duplicate of NM-3). Fixed by the same change.** The `value == 0` early return in
`_canAuthorizeAllowanceByModuleAndRevert` covers the frozen-spender and non-allowlisted-spender cases as well as
the paused case; see the Resolution under NM-3 and the regression tests
`testCanRevokeAllowanceWhenSpenderIsFrozen`, `testCanRevokeAllowanceWhenOwnerIsFrozen` and
`testCanRevokeAllowanceWhenSpenderIsNotAllowlisted`.

### NM-10 — Documented two-step default-admin protection is absent (Info → Informational)

**Claim.** *"The documented access-control model states that `DEFAULT_ADMIN_ROLE` is protected by OpenZeppelin's
`AccessControlDefaultAdminRules`"*, but `AccessControlModule` inherits plain `AccessControlUpgradeable`, so an
admin handover is immediate and unguarded — amplified by the `hasRole` override that grants the default admin every
role, including `PROXY_UPGRADE_ROLE` on `CMTATUpgradeableUUPS`.

**Verdict — rejected (false premise); the described behaviour is accurate and intentional.** No CMTAT
documentation claims `AccessControlDefaultAdminRules`. The only occurrences in the repository are inside
**OpenZeppelin's own source comments** carried into `doc/hardhat-compilation/v3.0.0/flatten/*.sol` (*"We recommend
using {AccessControlDefaultAdminRules}"*) — an OZ recommendation, not a CMTAT specification. The tool read a
vendored library comment as a project commitment.

The behaviour itself is by design: `contracts/modules/wrapper/security/AccessControlModule.sol` deliberately
overrides `hasRole` so that *"The Default Admin has all roles"*, and the initializer rejects `address(0)`. The
resulting centralization is the known, accepted governance trade-off for a regulated security token — the same
item tracked as Aderyn **L-1 Centralization Risk**, mitigated operationally at deployment (multisig / timelock /
separation of duties), not in code.

### NM-12 — `setDocument` emits raw user inputs instead of the engine's post-state (Info → Informational)

**Verdict — accepted as design; deliberate and already documented in code.**
`contracts/modules/wrapper/options/DocumentEngineModule.sol` carries an explicit comment explaining the choice:
the call is forwarded to the engine first (*"which reverts on invalid input"*), then the standard ERC-1643 event
is re-emitted **on the token's own address**, because ERC-1643 is a per-contract interface and integrators
subscribe to the token that exposes `setDocument` — without the re-emission the update would only be observable on
the engine's address. The engine emits on its own address as well. `removeDocument` reads the pre-state first
precisely because the spec requires the removed metadata in the event. This dual-emission is also the source of
the accepted Slither `reentrancy-events` / `unused-return` results. A document engine that silently normalizes or
ignores input would produce a divergent event — an engine-implementation contract, not a token defect.

### NM-13 / NM-14 / NM-19 — Engine setters accept `address(this)` and non-compliant addresses (Info ×3 → Informational)

**Claim.** `setDocumentEngine`, `setDebtEngine` and `setRuleEngine` validate only "different from the current
value"; they do not check for code, for `address(this)`, or for interface support. Setting the engine to
`address(this)` makes the delegated getters recurse until out of gas; setting it to an EOA makes reads revert on
ABI decoding, and (for ERC-1404) can make `_transferred` silently succeed against an EOA while `canTransfer`
reverts.

**Verdict — accepted as design.** Confirmed in
`contracts/modules/wrapper/options/DocumentEngineModule.sol`, `.../DebtEngineModule.sol` and
`.../extensions/ValidationModule/ValidationModuleRuleEngine.sol` — the only guard is
`CMTAT_*_SameValue()`. This is the same disposition as AuditAgent v3.1.0 finding #4 (*"Missing contract validation
for RuleEngine address"* — design choice: full validation is unreliable, and contract operators are expected to
know what they configure). Two properties bound the impact: the role required is a privileged one
(`DOCUMENT_ENGINE_ROLE` / `DEBT_ENGINE_ROLE` / `DEFAULT_ADMIN_ROLE`), and the misconfiguration is **always
recoverable** — the setters write storage without calling the engine, so a bad engine can be replaced at any time.

*Optional (cheap) hardening, not applied:* reject `address(this)` in the three setters. It closes the
self-recursion footgun for one comparison, without pretending to validate interface conformance.

### NM-15 / NM-17 — `setFrozenTokens` can freeze the zero address and brick every mint path (Info ×2 → **Low — FIXED**)

**Claim.** `_setFrozenTokens(account, value)` writes `_frozenTokens[account]` without rejecting
`account == address(0)`, unlike `_freezePartialTokens` / `_unfreezePartialTokens`, which explicitly do. Once
`getFrozenTokens(address(0))` is non-zero, every non-zero mint fails: the common mint path validates via
`_checkTransferred(_msgSender(), address(0), account, value)` → `_checkActiveBalanceAndRevert(address(0), value)`,
and since `balanceOf(address(0)) == 0`, the `frozenTokensLocal >= balance` branch returns `false` for any
`value > 0`.

**Verdict — VALID. This is the one substantive finding in the report, and it should be fixed.** Verified
end-to-end:

- `contracts/modules/internal/ERC20EnforcementModuleInternal.sol` — `_setFrozenTokens` has **no** zero-address
  guard, while `_freezePartialTokens` and `_unfreezePartialTokens` both open with
  `if (account == address(0)) revert CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();`. The inconsistency is
  internal to the same file.
- `_checkActiveBalance(address(0), value)`: `frozenTokensLocal > 0`, `balance == 0`, so `frozenTokensLocal >=
  balance` holds and the function returns `(false, 0)` for every `value > 0`.
- `contracts/modules/0_CMTATBaseCommon.sol` — `_mintOverride` calls `_checkTransferred(_msgSender(), address(0),
  account, value)`, which reaches `_checkActiveBalanceAndRevert(address(0), value)`.

**Impact.** A single `setFrozenTokens(address(0), 1)` disables `mint`, `batchMint`, `crosschainMint` and the mint
leg of `burnAndMint` across every `CMTATBaseCommon`-derived variant (Standard, Allowlist, RuleEngine, CrossChain,
ERC-1363, HolderList, Snapshot, Debt, Permit, ERC-7551). Primary issuance stops and inbound bridge settlement
stalls until it is cleared. The Light variants (`CMTATBaseCore`) are unaffected — they do not include
`ERC20EnforcementModule`, and their mint path calls `_canMintByModuleAndRevert` instead.

**Bounding it honestly.** This is *not* reachable by an unprivileged actor: `setFrozenTokens` is gated by
`onlyERC20Enforcer` (`ERC20ENFORCER_ROLE`). It is also fully self-recoverable — `setFrozenTokens(address(0), 0)`
takes the unfreeze branch and restores minting — and it destroys no funds. That is why it is Low, not Medium. But
it is a trivially avoidable footgun, it contradicts the guard already present two functions away in the same file,
and one operator typo (or one compromised enforcer key) halts issuance protocol-wide.

**Note on the sibling path.** `setAddressFrozen` (full-address freeze, `EnforcementModule`) is **not** affected:
`EnforcementModuleInternal._addAddressToTheList` already rejects `address(0)` with
`CMTAT_Enforcement_ZeroAddressNotAllowed()`. The defect was confined to the *partial*-freeze path, which made the
asymmetry within the enforcement modules the clearest evidence that this was an oversight rather than a decision.

**Resolution — fixed.**

- **Confirmation before fixing.** The behaviour was reproduced first. The repository already contained a test,
  `testSetFrozenTokensOnZeroAddressDoesNotBreakMintFlow`, whose **name asserted the opposite of its body**: it
  passed by requiring `mint` to revert with `ERC7943InsufficientUnfrozenBalance(address(0), 1, 0)` after
  `setFrozenTokens(address(0), 1)`. In other words the mint DoS was already pinned as expected behaviour under a
  reassuring name. Four new regression tests asserting the *correct* behaviour were added and confirmed **failing**
  on the unfixed code (`setFrozenTokens(address(0), 1)` did not revert).
- **Fix.** `contracts/modules/internal/ERC20EnforcementModuleInternal.sol` — `_setFrozenTokens` now opens with the
  same guard as its siblings:
  `if (account == address(0)) revert CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();`.
  The guard is placed before the value comparison so that `setFrozenTokens(address(0), 0)` also reports the
  zero-address error rather than `CMTAT_ERC20EnforcementModule_ValueEqualCurrentFrozenTokens`.
- **Tests.** `test/common/ERC20EnforcementModuleCommon.js` — added
  `testCannotSetFrozenTokensOnZeroAddress`, `testSetFrozenTokensOnZeroAddressCannotBrickMint`,
  `testSetFrozenTokensOnZeroAddressCannotBrickBatchMint`,
  `testCannotSetFrozenTokensOnZeroAddressEvenToZero` and `testSetFrozenTokensStillWorksOnRegularAddress` (the last
  one guards against regressing the normal path). The superseded
  `testSetFrozenTokensOnZeroAddressDoesNotBreakMintFlow` was **removed**: it asserted the pre-fix behaviour, and
  its stated intent is now covered — correctly — by `testSetFrozenTokensOnZeroAddressCannotBrickMint`.
- **Verification.** The new tests run through both the standalone and proxy enforcement suites
  (`test/standard/modules/ERC20EnforcementModule.test.js`, `test/proxy/modules/ERC20EnforcementModule.test.js`) —
  116 passing.

### NM-20 — Pausing disables privileged burn interfaces (Info → Informational)

**Claim.** Documentation says pausing blocks standard transfers but not privileged burns, yet
`_authorizeBurnFrom` and `_authorizeSelfBurn` carry `whenNotPaused`, so `burnFrom` and `burn(value)` revert while
paused even for role holders.

**Verdict — accepted as design; the "documentation says otherwise" premise is not backed by a CMTAT document.**
The behaviour is confirmed in `contracts/modules/5_CMTATBaseERC20CrossChain.sol`: `_authorizeBurnFrom`,
`_authorizeSelfBurn` and `_checkTokenBridge` are all `whenNotPaused` — intentionally, because pause is the
emergency stop for allowance-based and bridge-mediated supply movement. The issuer-controlled reduction path is
**not** blocked: the standard `BURNER_ROLE` burn (`ERC20BurnModule.burn`) routes to `_canBurnByModuleAndRevert`,
which checks deactivation and the target's frozen status but **not** pause, so it remains available while paused.
The report's premise conflates that path with the cross-chain overloads.

*Suggested (docs only):* state the split explicitly in the pause documentation — `BURNER_ROLE` burn survives
pause; `burnFrom` / self-burn / crosschain burn+mint do not.

### NM-21 — Mutable token name desynchronizes the EIP-712 domain separator (Info → Informational — **DOCUMENTED**)

**Claim.** `TokenAttributeModule.setName()` changes `name()`, but the EIP-712 domain separator was built from the
initial name and OpenZeppelin provides no way to update it, so `permit` suffers "a permanent denial of service"
after a rename.

**Verdict — accepted as design; accurate mechanism, overstated impact.** The mechanism is confirmed:
`contracts/modules/6_CMTATBaseERC2612.sol` initializes with `__EIP712_init_unchained(ERC20Attributes_.name, "1")`,
`EIP712Upgradeable` stores that name in its own ERC-7201 storage, and OZ documents that *"These parameters cannot
be changed except through a smart contract upgrade."* `setName` writes `TokenAttributeModule`'s storage only.

But `permit` does **not** break. The domain separator stays stable and valid, and the contract exposes ERC-5267
`eip712Domain()` (via `ERC20PermitUpgradeable` → `EIP712Upgradeable` → `IERC5267`), which returns the name
actually in use. Wallets and dApps that build the domain the standard way — from `eip712Domain()` — are unaffected.
Only integrators that derive the domain from `name()` would produce signatures that fail. So this is an
integration caveat, not a denial of service.

**Empirical confirmation.** Probed on `CMTATStandalonePermit` (throwaway test, not retained), calling
`setName("RENAMED TOKEN")` on a token deployed as `CMTA Token`:

| Observation | Result |
| --- | --- |
| `name()` after the rename | `RENAMED TOKEN` |
| `eip712Domain().name` after the rename | `CMTA Token` (unchanged) |
| `DOMAIN_SEPARATOR()` | unchanged |
| `permit` signed with the **new** `name()` | Reverts `ERC2612InvalidSigner` |
| `permit` signed with `eip712Domain().name` | **Succeeds** |

This settles the severity question: `permit` is **not** disabled by a rename. The report's *"permanent denial of
service for the `permit` functionality"* is incorrect — the function keeps working for any signer that discovers
the domain the standard way. Only an integration that hard-codes the domain from `name()` breaks, and it breaks
silently at the moment of the rename until a `permit` call reverts. That is an integration caveat worth
documenting, not a defect to fix. (Note that CMTAT's own `test/common/PermitModuleCommon.js` builds its domain
from `await this.cmtat.name()` — correct in the tests, since they never rename, but a fair illustration of how
natural the wrong pattern is.)

**Resolution — documented (no behaviour change).**

- `contracts/modules/wrapper/core/TokenAttributeModule.sol` — a `WARNING` block on `setName` states that the
  EIP-712 domain separator is not updated by a rename, that permits stay valid, and that signers must use
  `eip712Domain()` / `DOMAIN_SEPARATOR()` rather than `name()`, naming the `ERC2612InvalidSigner` failure mode.
- `contracts/modules/6_CMTATBaseERC2612.sol` — the same point, briefly, on `permit`.
- `doc/modules/options/erc2612/erc2612.md` — new section *"The EIP-712 domain name is fixed at deployment"* with
  the before/after table, the do/don't for building the domain, and a note for issuers who intend to use
  `setName` on a Permit deployment to confirm their integrators read `eip712Domain()`.
- `doc/modules/core/ERC20Base/ERC20base.md` — a cross-referencing note on the `setName(string)` reference entry.

The Solidity edits are comments only; the bytecode is unchanged.

### NM-22 — ERC-7551 `setTerms` overload silently erases the document name (Info → **Informational — FIXED**)

**Claim.** `ERC7551Module.setTerms(bytes32 hash_, string calldata uri_)` constructs
`IERC1643CMTAT.DocumentInfo("", uri_, hash_)` and forwards it to `_setTerms`, which overwrites the whole terms
struct — wiping a `name` previously set through `ExtraInformationModule.setTerms(DocumentInfo)`.

**Verdict — VALID (minor). Fixed.** Confirmed in
`contracts/modules/wrapper/options/ERC7551Module.sol` (the `""` literal) and
`contracts/modules/wrapper/extensions/ExtraInformationModule.sol`, where `_setTerms` unconditionally assigns
`$._terms.name = terms_.name`. The ERC-7551 signature carries no name, so the overload cannot supply one; the
result is silent data loss in on-chain terms metadata that off-chain legal/compliance references may rely on. No
funds or transfer logic are affected, and the name can be restored via the `DocumentInfo` overload — hence
Informational.

**Resolution — fixed.**

- **Confirmation before fixing.** As with NM-15, the repository already **pinned the erasure in a test**:
  `testAdminCanUpdateTerms` (`test/common/ERC7551ModuleCommon.js`) asserted the resulting name was `''` after an
  ERC-7551 `setTerms`, even though the token is deployed with the terms name `'doc1'`. A new test asserting the
  name is preserved was added first and confirmed **failing** (`expected '' to equal 'doc1'`).
- **Fix.**
  - `contracts/modules/wrapper/extensions/ExtraInformationModule.sol` — new internal
    `_setTermsDocument(bytes32 documentHash_, string memory uri_)` updates only the document part
    (`uri`, `documentHash`, `lastModified`) and emits the same `Terms($._terms)` event, leaving `$._terms.name`
    untouched.
  - `contracts/modules/wrapper/options/ERC7551Module.sol` — `setTerms(bytes32,string)` now calls
    `_setTermsDocument(hash_, uri_)` instead of building a `DocumentInfo("", uri_, hash_)` and routing it through
    `_setTerms`. The now-unused `IERC1643CMTAT` import was removed.
  - The `ICMTATBase` overload `setTerms(IERC1643CMTAT.DocumentInfo)` is unchanged: supplying a name explicitly
    still sets it, including to the empty string if that is what the caller passes.
  - Both events are still emitted exactly as before (`ICMTATBase.Terms(CMTATTerms)` from the module,
    `IERC7551Document.Terms(bytes32,string)` from the overload).
- **Tests.** `test/common/ERC7551ModuleCommon.js` — added `testERC7551SetTermsPreservesDocumentName` (asserts the
  uri and hash update while the name survives). The pre-existing `testAdminCanUpdateTerms` was updated: its
  expected name changed from `''` to `TERMS[0]`, since it had encoded the erasure as expected behaviour.
- **Verification.** ERC-7551 standalone + upgradeable suites: 476 passing. Full suite: **5868 passing, 87 pending,
  0 failing**.

### NM-23 — `detectTransferRestrictionFrom` reports `SPENDER_FROZEN` before deactivated/paused (Best Practices → Informational)

**Claim.** ERC-1404 restriction-code ordering requires `DEACTIVATED`, then `PAUSED`, then participant-frozen
codes. `ValidationModuleERC1404.detectTransferRestrictionFrom` evaluates `isFrozen(spender)` first, so a
deactivated-or-paused contract with a frozen spender returns code 5 instead of 1 or 2.

**Verdict — accepted as design (valid nit, no impact).** Confirmed in
`contracts/modules/wrapper/extensions/ValidationModule/ValidationModuleERC1404.sol`: the `isFrozen(spender)`
branch precedes `_detectTransferRestriction`, which is where the `deactivated()` / `paused()` checks live. The
report itself concludes correctly: *"because bad codes are non-zero, the transfer is still correctly predicted to
be blocked, so this is a reporting/state-drift inconsistency, not a bypass."* Only the *reason* an integrator
displays differs from the reason the enforcement path (`_canTransferStandardByModuleAndRevert`, which reverts on
pause first) would raise.

*Optional (cosmetic) reorder, not applied:* evaluate deactivated/paused before the spender-frozen branch so the
predicted reason matches the enforcement order.

### NM-24 — Unconditional `Spend` emission contradicts the interface documentation (Best Practices → **Informational — fix recommended**)

**Claim.** `ERC20BaseModule.transferFrom` emits `Spend` on every successful transfer, and
`ERC20CrossChainModule._burnFrom` emits it immediately after `_spendAllowance`, without suppressing the
infinite-allowance case — contradicting the documented semantics and poisoning event-driven allowance accounting.

**Verdict — VALID as a documentation defect. Recommended for fixing (NatSpec, not behaviour).** The two are in
direct contradiction:

- `contracts/interfaces/technical/IERC20Allowance.sol` — the `Spend` NatSpec states *"This event is **NOT**
  emitted when the allowance is infinite (`type(uint256).max`), because in that case OpenZeppelin does not reduce
  the allowance."*
- `contracts/modules/wrapper/core/ERC20BaseModule.sol` — `transferFrom` emits `Spend` whenever the transfer
  succeeds, with an inline comment saying the opposite: *"emit Spend does not necessarily imply an allowance
  reduction. This is the case if the allowance is set to `uint256.max`."*
- `contracts/modules/wrapper/options/ERC20CrossChainModule.sol` — `_burnFrom` likewise emits unconditionally.

The **implementation comment is correct and the interface NatSpec is stale.** This is the tail of Wake Arena
finding L1 (*"Misleading `Spend` event emitted on `transferFrom` when allowance is infinite"*, acknowledged with a
comment added): the comment landed in `ERC20BaseModule`, but the interface documentation that states the opposite
was never updated. An integrator reading the interface — the natural place to look — gets the wrong contract.

*Recommended fix (not applied by this triage):* correct the `IERC20Allowance.Spend` NatSpec to state that the
event **is** emitted on every allowance-consuming call, including infinite approvals, and that it therefore does
not by itself imply an allowance reduction. Behaviour unchanged.

---

## Delta from AuditAgent v3.1.0

The previous run (14 findings: 2 High, 2 Medium, 10 Low) was triaged as 7 invalid / 7 design choices, with no code
fix required; one item was later fixed anyway (v3.1.0 #13 → `approve` gained `whenNotPaused` in v3.2.0).

| Aspect | v3.1.0 | v3.3.0-rc2 |
| --- | --- | --- |
| Findings | 14 | 24 |
| Distribution | 2 H / 2 M / 10 L | 1 H / 4 M / 3 L / 14 Info / 2 BP |
| Fix required | none | 3 distinct items (NM-15/17, NM-22, NM-24) |

- **Carried over unchanged.** NM-1/NM-2 restate v3.1.0 #2 (proxy front-running — rejected then and now). NM-5
  restates #3 and #10 (spender not checked on mint/burn paths — design). NM-13/NM-14/NM-19 restate #4 (engine
  address not validated — design).
- **Caused by the v3.1.0 → v3.2.0 fix, and now reconciled.** NM-3 and NM-8 are the mirror image of v3.1.0 #13:
  having added `whenNotPaused` to `approve`, the tool now reports that holders cannot revoke allowances while
  restricted. The two runs ask for opposite behaviour, and both are right about their own case — so the fix splits
  them on the value: non-zero grants stay blocked (v3.1.0 #13 upheld), zero-value revocation is always allowed
  (NM-3/NM-8 fixed).
- **New surface, new findings.** The reentrancy-ordering cluster (NM-7/9/11/16/18) is reported for the first time
  and now spans the v3.3.0 additions (HolderList, ERC-1363, CrossChain wrappers). NM-15/NM-17, NM-22 and NM-24 are
  new and are the only items with a recommended code or documentation change.
- **Resolved from v3.1.0.** #1 (partial-freeze not enforced), #7 (unfreeze/balance reentrancy window), #9
  (SnapshotEngine hook bypass), #11 (forced transfers), #12 (deactivation handling) and #14 (ERC-2771 forwarder)
  do not reappear.

## Executive triage

**Nothing in this report is exploitable by an unprivileged actor, and no funds are at risk.** The single High
(NM-1) and its Medium duplicate (NM-2) are false positives — implementations call `_disableInitializers()` and
proxies are initialized atomically, a precondition the report itself admits it did not demonstrate. Of the
remaining three Mediums, NM-4 requires an administrator to grant `CROSS_CHAIN_ROLE` to the ERC-2771 forwarder —
the exact configuration the code comment forbids — and NM-3/NM-5 are documented design positions.

**Two defects were fixed; two minor items remain open:**

1. **NM-15 / NM-17 — `_setFrozenTokens` missing the zero-address guard** (`ERC20EnforcementModuleInternal.sol`).
   An `ERC20ENFORCER_ROLE` holder could halt all minting protocol-wide with one call. Privileged,
   self-recoverable, no fund loss — but it contradicted the guard already present in the sibling functions in the
   same file, and in `EnforcementModule`'s full-address freeze path. **FIXED** (guard added, 5 regression tests;
   a pre-existing test that pinned the buggy behaviour under a misleading name was removed).
2. **NM-3 / NM-8 — allowance revocation blocked while paused or restricted**
   (`ValidationModuleAllowance.sol` + 4 call sites). A holder could not zero out a stale allowance to a
   compromised, frozen or delisted spender for the duration of the restriction. **FIXED** — `value == 0` is now
   always authorized; non-zero grants remain gated exactly as before (7 regression tests, including two negative
   guards).
3. **NM-24 — `IERC20Allowance.Spend` NatSpec contradicts the implementation.** The interface says the event is not
   emitted for infinite allowances; both emit sites emit unconditionally. Documentation fix only. **Open.**
4. **NM-22 — ERC-7551 `setTerms` overload wipes the terms document name.** Minor, silent metadata loss.
   **Open — fix or document.**

**One follow-up came out of the NM-5 analysis and is not itself an AuditAgent finding:**
`doc/technical/access-control.md` claims that freezing a minter blocks minting (*"a frozen operator reverts with
`ERC7943CannotSend`"*). Tracing and probing the spender argument for NM-5 showed this is not the case — the
operator is propagated as `spender` but dropped by the mint/burn routing before any freeze check, and a frozen
`MINTER_ROLE` holder mints successfully. The contract behaviour is intended; the documentation describes a control
that does not exist. Worth correcting, since an operator could freeze a compromised minter and wrongly believe
issuance is stopped. See the follow-up under NM-5.

**One item deserves a decision rather than a patch:** the RuleEngine callback ordering (NM-7/9/11/16/18). The
ordering is real and confirmed, but it is only exploitable if the fully trusted, `DEFAULT_ADMIN_ROLE`-set
RuleEngine hands control to untrusted code. That trust assumption is what makes CMTAT safe here, and it is
currently **undocumented** — it should be written into
[`doc/modules/controllers/validationRuleEngine.md`](../../../../modules/controllers/validationRuleEngine.md).
Whether to additionally add a `nonReentrant` guard or move the callback after `_transfer` is a cost/semantics
trade-off for CMTA, not a defect to be patched silently.
