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

**5 fixed (behaviour) · 1 fixed (doc-only, NM-24) · 14 accepted as design · 4 rejected (false positive / false premise)** = 24.

Three defects were fixed in behaviour: **NM-15/NM-17** (zero-address freeze bricking every mint path),
**NM-3/NM-8** (allowance revocation blocked while paused or restricted) and **NM-22** (ERC-7551 `setTerms` erasing
the document name). The **NM-7 cluster** (RuleEngine reentrancy) is guarded on the deployment variants that have
bytecode headroom. **NM-24** was resolved doc-only (the `IERC20Allowance.Spend` NatSpec was corrected). NM-4, NM-6,
NM-20 and NM-21 were documented rather than changed. **No item is left open**, and none of the 24 findings is
exploitable by an unprivileged actor.

## Findings triage

| ID | Severity (tool → ours) | Disposition | Status |
| --- | --- | --- | --- |
| NM-1 | High → Informational | Rejected (false positive) | Closed |
| NM-2 | Medium → Informational | Rejected (duplicate of NM-1) | Closed |
| NM-3 | Medium → Low | **Fixed** | **Fixed** — revocation (`value == 0`) always authorized |
| NM-4 | Medium → Informational | Rejected (design; misconfiguration precondition) — **documented** | Closed — deployment constraint documented |
| NM-5 | Medium → Informational | Accepted as design — Light minter-transfer spender **aligned** with the full base (behaviour-neutral) | Partially addressed (see follow-up on `access-control.md`) |
| NM-6 | Low → Informational | Accepted as design (RuleEngine responsibility) — **documented** | Accepted — doc + NatSpec added |
| NM-7 | Low → Low | **Partially fixed** — guard on variants with size headroom | **Fixed (guarded variants)** / documented elsewhere |
| NM-8 | Low → Low | **Fixed (same change as NM-3)** | **Fixed** |
| NM-9 | Info → Low | **Partially fixed (same change as NM-7)** | **Fixed (guarded variants)** |
| NM-10 | Info → Informational | Rejected (false premise) | Closed |
| NM-11 | Info → Low | **Partially fixed (same change as NM-7)** | **Fixed (guarded variants)** |
| NM-12 | Info → Informational | Accepted as design | Accepted |
| NM-13 | Info → Informational | Accepted as design — hardening tracked | Accepted ([#395](https://github.com/CMTA/CMTAT/issues/395)) |
| NM-14 | Info → Informational | Accepted as design — hardening tracked | Accepted ([#395](https://github.com/CMTA/CMTAT/issues/395)) |
| **NM-15** | **Info → Low** | **Fixed** | **Fixed** — zero-address guard in `_setFrozenTokens` |
| NM-16 | Info → Low | **Partially fixed (same change as NM-7)** | **Fixed (guarded variants)** |
| **NM-17** | **Info → Low** | **Fixed (same defect as NM-15)** | **Fixed** |
| NM-18 | Info → Informational | **Partially fixed (same change as NM-7)** | **Fixed (guarded variants)** |
| NM-19 | Info → Informational | Accepted as design — hardening tracked | Accepted ([#395](https://github.com/CMTA/CMTAT/issues/395)) |
| NM-20 | Info → Informational | Accepted as design — issuer vs third-party split, probed — **documented** | Accepted — rationale documented |
| NM-21 | Info → Informational | Accepted as design (claim overstated) — **documented** | Accepted — doc + NatSpec added |
| **NM-22** | **Info → Informational** | **Fixed** | **Fixed** — ERC-7551 overload preserves the name |
| NM-23 | Best Practices → Informational | Accepted as design — reorder options + drawbacks documented | Accepted (Variant 1 suggested, not applied) |
| **NM-24** | **Best Practices → Informational** | **Fixed (doc-only)** — NatSpec corrected; consistency improvement recorded in technical doc | **Fixed (documented)** |

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

### NM-5 — Missing freeze enforcement on `spender` for `burnFrom` and minter transfers (Medium → Informational — **partially addressed**)

**Claim.** Burn routing checks only `from`; `CMTATBaseCore._minterTransferOverride` hardcodes `address(0)` as the
spender; `CMTATBaseCommon._checkTransferred` ignores its `spender` argument entirely.

**Verdict — accepted as design; the Light-variant inconsistency was aligned.** All three observations are factually
correct. The one that was a genuine *inconsistency* — `CMTATBaseCore` (Light) hardcoding `address(0)` where the
full base passes `_msgSender()` — has been fixed for uniformity (see Resolution below). The rest stands as
design.

- `contracts/modules/0_CMTATBaseCore.sol` — `_minterTransferOverride` **now** calls
  `ValidationModule._canTransferGenericByModuleAndRevert(_msgSender(), from, to)` (was `address(0)`).
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

**`CMTATBaseCore` (Light variants):**

| Path | Call | `spender` |
| --- | --- | --- |
| `_mintOverride` | `_canMintByModuleAndRevert(account)` | n/a — not a spender-parameterized function |
| `_burnOverride` | `_canBurnByModuleAndRevert(account)` | n/a |
| `_minterTransferOverride` | `_canTransferGenericByModuleAndRevert(_msgSender(), from, to)` | the minter *(aligned — was `address(0)`)* |

The report's specific claim about `CMTATBaseCore._minterTransferOverride` hardcoding `address(0)` was accurate at
triage. It has since been changed to pass `_msgSender()`, matching `CMTATBaseCommon` (see Resolution). The mint and
burn overrides remain `spender`-free by structure, as in the full base.

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

This is **not** part of NM-5 (the tool did not report it, and the contract behaviour is intended). It was a
documented security control that did not exist as described — a reader could have frozen a compromised minter and
believed issuance was stopped.

**Resolved (documentation).** CMTA chose to keep the minter behaviour unchanged (freezing is holder-level;
`revokeRole` is the operator lever) and correct the documentation instead. `doc/technical/access-control.md` now
states that freezing an operator does **not** block `mint`/`batchMint` (only the recipient and deactivation are
checked), that it **does** block the operator's `batchTransfer`/`transfer`/`transferFrom` (operator is the
sender/spender), and that on the Standard version a configured RuleEngine still receives the operator as `spender`
and may reject. A per-operation × per-deployment table was added there, with condensed versions in `doc/README.md`
(Enforcement chapter) and the `ERC20Mint` module page.

#### Resolution — Light minter-transfer aligned with the full base (no behaviour change)

`contracts/modules/0_CMTATBaseCore.sol` — `_minterTransferOverride` now passes `_msgSender()` as the spender
instead of a hardcoded `address(0)`, matching `CMTATBaseCommon._minterTransferOverride` and the `transferFrom`
path. This removes the one genuine *inconsistency* the finding pointed at (the Light base treated its minter
transfers differently from every other base).

The change is **behaviour-neutral**. `_minterTransferOverride` is only ever reached from
`ERC20MintModuleInternal._batchTransfer`, which passes `from = _msgSender()`, so `spender == from` on this path.
In `_canTransferisFrozenAndRevert` the spender is checked before `from`, but both are the same address, so the
revert (a frozen minter → `ERC7943CannotSend(minter)`) and the outcome are identical to before; only the argument
is now threaded consistently. Light adds no bytecode (`CMTATStandaloneLight` unchanged at 11 562 bytes). It does
**not** change the mint/burn paths — those remain `spender`-free by structure in both bases, so the
freeze-does-not-block-a-minter behaviour probed above is unchanged, as is the `access-control.md` follow-up.

Regression test: `test/common/ERC20MintModuleCommon.js` — `testCannotBatchTransferIfMinterIsFrozen` asserts a
frozen minter's `batchTransfer` reverts with `ERC7943CannotSend(minter)`, run across the Light and full variants.

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

#### Reproduction — the exploit is real, given its precondition

The cluster was reproduced end to end before deciding anything, with a purpose-built malicious engine
(`contracts/mocks/RuleEngine/RuleEngineReentrantMock.sol`) that performs one nested `transferFrom` during the
`transferred` callback.

A first attempt **failed**, and the failure is informative: the engine called
`transferFrom(victim, attacker, 40)` and got `ERC20InsufficientAllowance(engine, 0, 40)`. The nested call executes
with the *engine* as `msg.sender`, so the engine — not the attacker — needs the allowance. Reentrancy alone is not
enough; the reentering party must already be authorized. That is exactly the precondition NM-9 states (*"if the
rule-engine address has spender allowance from a partially frozen holder"*), and NM-16's variant (an engine that
calls attacker-controlled code, letting the attacker's own allowance be used) is the other way to satisfy it.

With the precondition satisfied, on an unguarded build:

| | `balanceOf(victim)` | `frozenTokens` | attacker received | `frozenTokens <= balanceOf` |
| --- | ---: | ---: | ---: | :---: |
| Before | 100 | 60 (active 40) | — | holds |
| After outer `transferFrom(victim, attacker, 40)` + one nested 40 | **20** | 60 | **80** | **BROKEN** |

80 tokens moved on a 40-token unfrozen allowance, and the freeze invariant was left violated. With the guard the
same scenario moves exactly 40 and the invariant holds.

**Resolution — guard added, on the variants that can carry it.**

- `ValidationModuleRuleEngine` now isolates the external call in an `internal virtual`
  `_callRuleEngineTransferred(...)`. The base implementation is **unguarded**.
- Deployment variants with bytecode headroom inherit OpenZeppelin's `ReentrancyGuardTransient` and override that
  function with `nonReentrant`. The **transient (EIP-1153)** guard is used rather than the storage-based one so no
  storage slot is added: existing upgradeable proxies keep their layout and no initializer has to run.
- The guard is entered **only when a RuleEngine is set**, and released when the callback returns, so deployments
  without an engine pay nothing and sequential hooks (`batchMint`, `burnAndMint`) are unaffected.

**Why not everywhere — measured.** The guard costs ~195 bytes of deployed bytecode. Several variants are within a
few hundred bytes of the EIP-170 24 576-byte limit, and enabling it there makes them **undeployable**:

| Variant | Unguarded | Guard | Result |
| --- | ---: | :---: | --- |
| `CMTATStandaloneSnapshot` / `CMTATUpgradeableSnapshot` | 22 664 | ✅ | 22 859 |
| `CMTATStandardStandalone` / `CMTATStandardUpgradeable` | 22 844 | ✅ | 23 039 |
| `CMTATStandaloneERC7551` / `CMTATUpgradeableERC7551` | 23 536 | ✅ | 23 731 |
| `CMTATStandaloneDebt` / `CMTATUpgradeableDebt` | 23 805 | ❌ | — |
| `CMTATStandalonePermit` / `CMTATUpgradeablePermit` | 23 961 | ❌ | — |
| `CMTATUpgradeableUUPS` | 24 176 | ❌ | — |
| `CMTATStandaloneDebtEngine` / `CMTATUpgradeableDebtEngine` | 24 429 | ❌ | would be 24 624 — **over limit** |
| `CMTATStandaloneERC1363` / `CMTATUpgradeableERC1363` | 24 443 | ❌ | would be 24 638 — **over limit** |
| `CMTATStandaloneHolderList` / `CMTATUpgradeableHolderList` | 24 456 | ❌ | would be 24 651 — **over limit** |
| Allowlist / Light variants | 20 405 / 11 562 | n/a | no RuleEngine — never reach this code |

The selection rule applied is *unguarded size below 23 KiB*. An earlier iteration used a hand-rolled inline
transient guard (119 bytes instead of 195) to fit more variants; it was **rejected** in favour of the audited
OpenZeppelin library, because the 76 bytes saved still left `HolderList` at 1 byte of headroom — not a real margin
— and because the hand-rolled version used `tload`/`tstore` under a `^0.8.20` pragma, which would have failed with
a confusing assembly error on 0.8.20–0.8.23 instead of a clean pragma error.

- **Tests.** `test/common/ValidationModule/RuleEngineReentrancyCommon.js` — 7 tests run against a guarded
  standalone and a guarded proxy variant: the drain is blocked, the nested call is rejected, the reentrant call
  reverts with `ReentrancyGuardReentrantCall` when the engine propagates it, the direct `transfer` path is guarded
  too, and normal transfers / consecutive transfers / `batchMint` still work (proving the guard does not leak
  across sequential callbacks).
- **Compiler floor raised.** `ReentrancyGuardTransient` requires EIP-1153 transient storage and declares
  `pragma solidity ^0.8.24`, so the project can no longer be compiled at 0.8.20–0.8.23. All **128** contract files
  were moved from `^0.8.20` (and one stray `^0.8.0`) to **`^0.8.24`**, so every file declares the real floor
  instead of a version the build does not support. The pinned compiler is unchanged (0.8.34 in `hardhat.config.js`
  and `foundry.toml`), and the Aderyn L-3 *"Unspecific Solidity Pragma"* disposition was updated to match.
- **Documentation.** `doc/modules/controllers/validationRuleEngine.md` gained a section with the per-variant table
  and an explicit **WARNING** that on unguarded variants the trust assumption is load-bearing: the RuleEngine is
  set by `DEFAULT_ADMIN_ROLE`, is fully trusted, and **MUST NOT** transfer control to untrusted code during
  `transferred(...)`. It also explains how to enable the guard on another variant and to re-check the size.

**Residual risk.** On the ❌ variants the behaviour is unchanged and the finding stands as originally triaged —
accepted as design, mitigated by the trust assumption, now documented rather than implied. NM-18's read-only
reentrancy (a third-party protocol reading `balanceOf` during the callback) is likewise unchanged on those
variants.

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

**Tracked for a possible future release:** [CMTA/CMTAT#395](https://github.com/CMTA/CMTAT/issues/395) — validate
engines with ERC-165 in `setRuleEngine` / `setDocumentEngine` / `setDebtEngine`. Two notes from scoping that issue:

- The RuleEngine case is nearly free — `IRuleEngine` **already extends `IERC165`**, and
  `RuleEngineInterfaceId.RULE_ENGINE_INTERFACE_ID` / `ERC1404ExtendInterfaceId.ERC1404EXTEND_INTERFACE_ID` already
  exist as libraries, with `RuleEngineMock` and `contracts/mocks/ERC165Helper/` already implementing them. Only the
  setter check is missing. It is also the highest-value case: an EOA rule engine makes `transferred(...)` succeed
  silently, so transfers proceed with **all compliance rules bypassed** — the only one of the three that fails
  *open*.
- `IERC1643` and `IDebtEngine` do **not** extend `IERC165`, so requiring it there is a breaking change for
  already-deployed engines, and the check would add code to variants that have under 1 KiB of headroom against the
  EIP-170 limit (`CMTATStandaloneHolderList` 23.870 KiB, `CMTATStandaloneERC1363` 23.857 KiB,
  `CMTATStandaloneDebtEngine` 23.844 KiB).

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

### NM-20 — Pausing disables privileged burn interfaces (Info → Informational — **DOCUMENTED**)

> **Summary:** correct behaviour. Pause stops **third-party / bridge** supply operations and leaves **issuer**
> operations available. The rationale was already in `doc/README.md`; the gap was module-level scoping in
> `ERC20Burn.md`, now fixed.

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

#### The split is issuer operations vs third-party (bridge) operations

The distinction the report missed is not "some burns are gated and some are not" — it is **who is acting**:

- **Issuer operations** (`ERC20BurnModule`, `ERC20MintModule`, enforcement) express the issuer's own control over
  supply. Pause is an emergency stop on *circulation*, not on the issuer's ability to manage the instrument, so
  these must keep working while paused — that is the whole point of being able to pause.
- **Third-party operations** (`ERC20CrossChainModule`) are performed by a **bridge or an allowance-holding
  operator**, not by the issuer. `burnFrom` spends someone else's allowance; `burn(uint256)` is a self-burn by a
  bridge-side actor holding `BURNER_SELF_ROLE`; `crosschainMint` / `crosschainBurn` are the ERC-7802 bridge
  entry points. These are exactly the flows a pause is meant to halt: while the token is paused, cross-chain
  settlement must stop rather than continue moving supply between chains against a frozen local state.

Read that way, `whenNotPaused` on `_authorizeBurnFrom`, `_authorizeSelfBurn` and `_checkTokenBridge` is not an
inconsistency with the issuer burn path — it is the line between the two categories, drawn deliberately.

#### Measured behaviour

Probed on `CMTATStandardStandalone` with the contract paused (throwaway test, not retained):

| Path | Module | Role | While paused |
| --- | --- | --- | --- |
| `burn(address,uint256)` | `ERC20BurnModule` (issuer) | `BURNER_ROLE` | **Allowed** |
| `batchBurn(address[],uint256[])` | `ERC20BurnModule` (issuer) | `BURNER_ROLE` | **Allowed** |
| `mint(address,uint256)` | `ERC20MintModule` (issuer) | `MINTER_ROLE` | **Allowed** |
| `forcedTransfer(...)` | `ERC20EnforcementModule` (issuer/enforcement) | `DEFAULT_ADMIN_ROLE` | **Allowed** |
| `burnFrom(address,uint256)` | `ERC20CrossChainModule` (third party) | `BURNER_FROM_ROLE` | **Blocked** — `EnforcedPause()` |
| `burn(uint256)` self-burn | `ERC20CrossChainModule` (third party) | `BURNER_SELF_ROLE` | **Blocked** — `EnforcedPause()` |
| `crosschainBurn(address,uint256)` | `ERC20CrossChainModule` (bridge) | `CROSS_CHAIN_ROLE` | **Blocked** — `EnforcedPause()` |
| `crosschainMint(address,uint256)` | `ERC20CrossChainModule` (bridge) | `CROSS_CHAIN_ROLE` | **Blocked** — `EnforcedPause()` |

The split is clean along the issuer / third-party line, with no exceptions. (`forcedBurn` is a `CMTATBaseCore`
function and is therefore absent from the full variants; on the Light variants it is gated only by
`DEFAULT_ADMIN_ROLE`, so it too survives pause — consistent with the issuer-operation rule.)

#### Is this already documented? Yes — including the rationale

The behaviour **and** its rationale were already written down. `doc/README.md`, under *Pause & Deactivate contract
(PauseModule) → Note*, states both halves explicitly:

> The pause function does not affect burn and mint operations implemented in the contracts `ERC20MintModule` and
> `ERC20BurnModule`. By separating burn/mint from standard transfer, the admin can re-adjust the supply while the
> standard transfers are paused. […] On the other hand, specific function for cross-chain bridge
> (`5_CMTATBaseERC20CrossChain.sol`) **will revert if contract is paused because they are not intended to be used
> by the issuer to manage the supply**.

That last clause is precisely the issuer-vs-third-party principle. The per-function facts are documented too:

| Statement | Where |
| --- | --- |
| Rationale — issuer supply management vs cross-chain bridge functions | `doc/README.md` (*Pause & Deactivate → Note*) |
| *"Burn can occur even if transfers are paused."* | `doc/modules/core/ERC20Burn/ERC20Burn.md` |
| *"If the interface `{IERC7551Pause}` is implemented, minting is allowed even when transfers are paused."* | `doc/modules/core/ERC20Mint/ERC20Mint.md` |
| *"The contract must not be paused — error: `EnforcedPause()`"* on `crosschainMint`, `crosschainBurn`, `burnFrom` and `burn(uint256)` | `doc/modules/options/erc20crosschain/ERC20CrossChain.md` |

So the report's premise — that documentation promises privileged burns remain available — is **half true** in a
narrower sense than first assessed: `doc/README.md` is correct and complete, but the *module-level* page
`ERC20Burn.md` states "burn can occur even if transfers are paused" without scoping it to `ERC20BurnModule`. An
integrator reading only that page and then calling `ERC20CrossChainModule.burnFrom` would be surprised. Given the
two functions share the name `burn`, that is the most plausible route to the finding.

> **Correction.** An earlier revision of this entry stated that the rationale was undocumented. That was wrong —
> it is in `doc/README.md`, which the initial search did not cover. The gap was narrower: module-level scoping,
> not a missing rationale.

**Resolution — documented (no behaviour change).** Since `doc/README.md` already carried the rationale, the work
was to propagate it to the module pages where the ambiguity actually bites, and to remove the over-promise.

- `doc/modules/core/ERC20Burn/ERC20Burn.md` — **the important edit.** The *"Burn can occur even if transfers are
  paused"* note is now scoped to the issuer burn it documents, and states that the `ERC20CrossChainModule` burns
  are blocked. This is the sentence that most plausibly produced the finding.
- `doc/modules/core/Pause/pause.md` — new section *"What pause stops, and what it does not"*, stating the
  issuer-vs-third-party principle and tabulating every affected path (mint, issuer burn, enforcement, holder
  transfers, the four `ERC20CrossChainModule` entry points, and both `approve` cases), closing on the `burn`
  name collision. The Rationale section also gained a sentence on the NM-3 revocation carve-out, which the pause
  documentation still described in pre-v3.2.0 terms.
- `doc/modules/options/erc20crosschain/ERC20CrossChain.md` — a note directly under the title covering all four
  entry points, with the reason and the same warning about the two `burn` overloads.
- `doc/README.md` — the existing *Pause & Deactivate → Note* was **extended in place** (not duplicated elsewhere)
  with the per-path table, the `burn` name-collision warning and the allowance-revocation carve-out.

The per-function requirement lists were not changed — they were already accurate.

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

#### What the fix would change in code

Today `detectTransferRestrictionFrom` checks the spender first, then delegates the rest to
`_detectTransferRestriction`, which holds the deactivated/paused checks:

```solidity
function detectTransferRestrictionFrom(address spender, address from, address to, uint256 value) ... {
    if (isFrozen(spender)) {                                   // <-- evaluated before deactivated/paused
        return TRANSFER_REJECTED_SPENDER_FROZEN;               //     (code 5)
    } else {
        uint8 codeReturn = _detectTransferRestriction(from, to, value); // deactivated(1) → paused(2) → from(3) → to(4)
        ...
    }
}
```

The required order is deactivated (1) → paused (2) → **then** the frozen-participant codes. Two ways to get there,
each with a different trade-off:

**Variant 1 — delegate first, check the spender last (smallest, reorders among the frozen codes).**

```solidity
uint8 codeReturn = _detectTransferRestriction(from, to, value); // deactivated → paused → from → to
if (codeReturn != TRANSFER_OK) {
    return codeReturn;
} else if (isFrozen(spender)) {
    return TRANSFER_REJECTED_SPENDER_FROZEN;
} else if (address(ruleEngine_) != address(0)) {
    return ruleEngine_.detectTransferRestrictionFrom(spender, from, to, value);
} else {
    return TRANSFER_OK;
}
```

This satisfies the invariant (deactivated/paused always precede `SPENDER_FROZEN`) with essentially no size change,
but it also moves the spender-frozen code from *first* to *last* among the frozen codes: when the spender **and**
`from`/`to` are all frozen, the function now returns `FROM_FROZEN`/`TO_FROZEN` instead of `SPENDER_FROZEN`. That is
a second, subtler change to the reported reason.

**Variant 2 — evaluate deactivated/paused inline before the spender branch (preserves spender-first, costs a little
size).**

```solidity
if (deactivated())       return TRANSFER_REJECTED_DEACTIVATED;
else if (paused())       return TRANSFER_REJECTED_PAUSED;
else if (isFrozen(spender)) return TRANSFER_REJECTED_SPENDER_FROZEN;
else { uint8 codeReturn = _detectTransferRestriction(from, to, value); ... }
```

This keeps `SPENDER_FROZEN` ahead of `FROM_FROZEN`/`TO_FROZEN`, but the `deactivated()`/`paused()` checks now run
**twice** (again inside `_detectTransferRestriction`) — two redundant `SLOAD`s and a few extra bytes of bytecode
on contracts (`ERC1363`, `HolderList`, `DebtEngine`) that are already within a few hundred bytes of the EIP-170
limit. `detectTransferRestrictionFrom` is a `view`, so the gas is only paid by off-chain callers, but the size is
paid at deploy time regardless.

#### Drawbacks common to both

- **It is an observable change to a returned value.** For the specific state (contract deactivated or paused **and**
  the spender frozen) the function returns a different non-zero code than before. No transfer outcome changes — the
  transfer is still predicted blocked, and the enforcement path is untouched — but any off-chain integrator
  (exchange, wallet) that keys UI or logic on the exact code sees a different reason. That is precisely the class
  of consumer ERC-1404 restriction codes exist for, so it is not purely internal.
- **No on-chain benefit.** The write path (`_canTransferStandardByModuleAndRevert`) already reverts on pause before
  any frozen check, so the fix only aligns the *predicted* reason with the *enforced* reason; it removes a
  reporting/state-drift inconsistency, nothing more.
- `messageForTransferRestriction` needs no change — the code *values* are unchanged, only which one is returned in
  the overlap case.

**Recommendation.** Low priority; if applied, prefer **Variant 1** — it matches the invariant the finding asks for
with no size cost, and the spender-vs-from/to reordering it introduces is within the "frozen participant" group the
spec does not order internally. Because it is nonetheless an observable code change for integrators, it is best
bundled into a release that already touches the ERC-1404 surface rather than shipped on its own. Left unapplied by
this triage.

### NM-24 — Unconditional `Spend` emission contradicts the interface documentation (Best Practices → **Informational — FIXED (doc-only)**)

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

#### `transferFrom` vs `burnFrom` — the two emit sites differ

There are exactly two `Spend` emit sites in the codebase. They agree on the defect but differ in three ways that
matter to an indexer.

| | `ERC20BaseModule.transferFrom` | `ERC20CrossChainModule._burnFrom` |
| --- | --- | --- |
| Available on | every variant with an allowance surface | CrossChain-derived variants only |
| Allowance spent by | `ERC20Upgradeable.transferFrom` (internally) | an explicit `ERC20Upgradeable._spendAllowance(account, sender, value)` |
| Emitted | **after** the transfer completes | **between** `_spendAllowance` and the burn |
| Guarded | `if (result) { … }` | unconditional |
| Spender argument | `_msgSender()`, read at emit time | the `sender` parameter, captured in `burnFrom` as `_msgSender()` |
| Event order in the receipt | `Transfer` → `Spend` | `Spend` → `Transfer` → `BurnFrom` |

The **event ordering is inverted** between the two paths, confirmed by probe (throwaway test, not retained):

```
transferFrom (infinite): [Transfer -> Spend]
burnFrom     (infinite): [Spend -> Transfer -> BurnFrom]
transferFrom (finite)  : [Transfer -> Spend]
burnFrom     (finite)  : [Spend -> Transfer -> BurnFrom]
```

This falls out of where each site sits: `ERC20BaseModule` wraps the OpenZeppelin call and emits once it returns,
whereas `_burnFrom` emits between spending the allowance and performing the burn. An indexer that pairs a `Spend`
with the *following* `Transfer` will mis-associate them on one of the two paths. Neither ordering is wrong, but
they are not consistent with each other, and nothing documents that.

The `if (result)` guard on `transferFrom` is vacuous — `ERC20Upgradeable.transferFrom` either returns `true` or
reverts — so both sites are unconditional in practice. The difference is cosmetic but makes one site *look*
conditional and the other not.

The self-burn path `burn(uint256)` correctly emits **no** `Spend`: it calls `_burnFromOperator` directly, without
`_spendAllowance`, because no allowance is involved.

#### The report found half of the accounting drift

Probed on `CMTATStandardStandalone`:

| Path | Allowance actually reduced? | `Spend` emitted? | Result |
| --- | --- | --- | --- |
| `transferFrom`, finite allowance | Yes | Yes | Correct |
| `transferFrom`, infinite allowance | **No** (stays `type(uint256).max`) | **Yes** | **Over-reports** — the NM-24 case |
| `burnFrom`, finite allowance | Yes | Yes | Correct |
| `burnFrom`, infinite allowance | **No** (stays `type(uint256).max`) | **Yes** | **Over-reports** — the NM-24 case |
| `forcedTransfer` against an existing allowance | **Yes** (500 → 490) | **No** | **Under-reports** — not in the report |

The last row is the mirror image of the finding and the tool did not surface it.
`ERC20EnforcementModuleInternal._forcedTransfer` reduces the owner→recipient allowance when one exists, using
`ERC20Upgradeable._approve(from, to, …, false)`. The trailing `false` suppresses the `Approval` event, and no
`Spend` is emitted either, so a forced transfer silently consumes allowance with **no allowance-related event at
all** — the observed receipt is `[Transfer -> ForcedTransfer]` while the allowance moves from 500 to 490.

> **Update (applied):** the `forcedTransfer` row above describes the state at triage. It has since been fixed —
> `_forcedTransfer` now emits `Spend` on the allowance reduction (see Resolution below), so that path no longer
> under-reports. The `transferFrom`/`burnFrom` over-report on infinite approvals is unchanged.

So an integrator reconstructing allowances purely from events drifts in *both* directions: too low after an
infinite-approval `transferFrom`/`burnFrom`, and too high after a `forcedTransfer`. Any correct integration must
read `allowance()` rather than accumulate events — which is the substantive guidance, and is what the corrected
NatSpec should say.

The `forcedTransfer` behaviour is arguably intended (an enforcement action is not a spend by the spender, and the
suppressed `Approval` avoids implying the *owner* re-approved), but it is undocumented, and it is the more
surprising of the two directions.

#### Making the two paths consistent — options, drawbacks, recommendation

If CMTA wants `transferFrom` and `burnFrom` to emit `Spend` **identically** (same ordering, same
infinite-allowance handling), there are three ways to get there. They differ in how much behaviour they change and
what they cost.

**Option A — emit `Spend` from a single overridden `_spendAllowance` (behaviour change; reconciles code with the
interface).** Both paths already funnel their allowance spend through OpenZeppelin's
`ERC20Upgradeable._spendAllowance(owner, spender, value)` — `transferFrom` calls it internally, `_burnFrom` calls
it explicitly. That function reduces the allowance **only when it is finite** (`currentAllowance < type(uint256).max`).
Overriding it once, emitting `Spend` inside that same finite branch, and deleting the two explicit `emit Spend`
statements would make the two paths identical *and* make the behaviour match what `IERC20Allowance.Spend` already
claims — no `Spend` on an infinite allowance:

```solidity
function _spendAllowance(address owner, address spender, uint256 value) internal virtual override {
    if (allowance(owner, spender) != type(uint256).max) {
        emit IERC20Allowance.Spend(owner, spender, value);
    }
    super._spendAllowance(owner, spender, value);
}
```

- *Upside:* one emit site, one ordering (`Spend` → `Transfer` on both paths), and the interface NatSpec becomes
  true as written instead of needing correction.
- *Drawbacks:* (1) it is an **observable behaviour change** — `Spend` stops being emitted for infinite-allowance
  spends, and the `transferFrom` order flips from `Transfer → Spend` to `Spend → Transfer`; any existing indexer
  keyed on either is broken, so this belongs in a **major version**, not a patch. (2) The `allowance(...)` read in
  the override is an **extra `SLOAD` on every `transferFrom`** — the hottest path in the token — unless
  `_spendAllowance` is fully re-implemented to reuse the value it already loads, which means diverging from the
  audited OpenZeppelin body. (3) It removes the "a delegated spend happened" signal that infinite-approval
  integrators may currently rely on. (4) It does **not** address the `forcedTransfer` gap (that path never touches
  `_spendAllowance`).

**Option B — reorder `_burnFrom` so its `Spend` is emitted after the burn (ordering only).** Move the `emit Spend`
in `ERC20CrossChainModule._burnFrom` to after `_burnFromOperator`, giving `Transfer → BurnFrom → Spend` so that
`Spend` is last on both paths.

- *Upside:* cheapest possible change — no gas cost, no size cost, no infinite-allowance semantics change.
- *Drawbacks:* it only aligns the *ordering*, so the actual NM-24 contradiction (emission on infinite allowance)
  is untouched and still needs the NatSpec fix anyway; it decouples the `Spend` event from the `_spendAllowance`
  call it represents, so the code reads less obviously; and it is still an observable change for any indexer keyed
  on the current order. Cosmetic alignment for cosmetic inconsistency — little is actually bought.

**Option 0 — document only (no code change).** Correct the `IERC20Allowance.Spend` NatSpec, and note the ordering
difference and the `forcedTransfer` gap.

- *Upside:* no gas, no bytecode, no behaviour change, nothing broken for existing integrators. The one piece of
  guidance that actually matters — *reconstruct allowances from `allowance()`, never by summing `Spend` events* —
  is a documentation fix in every option, so it fully resolves the integrator-facing problem on its own.
- *Drawback:* the two paths stay cosmetically inconsistent (different event order); integrators have to read the
  note rather than infer a single rule from behaviour.

**Recommendation — Option 0 (document only).** The inconsistency is real but harmless: no funds, no accounting
error for anyone who reads `allowance()`, and the two "wrong" directions (over-report on infinite approvals,
under-report on `forcedTransfer`) are both event-only. Every code option imposes an observable behaviour change —
and Option A additionally adds an `SLOAD` to the busiest function in the contract and risks the EIP-170 size limit
on the variants that are already within a few hundred bytes of it. Spending gas and a breaking change to make a
cosmetic difference disappear is a poor trade when the correctness guidance is a doc fix regardless. If CMTA does
want the interface's current "no `Spend` on infinite" wording to become literally true, that is **Option A,
deferred to a major version**, done together with the same treatment for `forcedTransfer`.

**Resolution — documentation, plus one small behaviour change to close the `forcedTransfer` under-report.**

- `contracts/modules/internal/ERC20EnforcementModuleInternal.sol` — **behaviour change.** `_forcedTransfer` now
  emits `IERC20Allowance.Spend(from, to, spentAllowance)` when it reduces a finite, non-zero `from`→`to` allowance
  (`spentAllowance = min(currentAllowance, value)`). This closes the under-report row above: the reduction is no
  longer silent. The allowance-reduction logic is unchanged (the `_approve(..., false)` still suppresses
  `Approval`); only the `Spend` emission is added. Measured cost: +72 bytes on the tightest variant
  (`CMTATStandaloneHolderList`, now 24 528 / 24 576 — 48 bytes of headroom), within limit on all variants.
- `contracts/interfaces/technical/IERC20Allowance.sol` — the `Spend` NatSpec was corrected. It previously claimed
  the event is *not* emitted for infinite allowances (the reverse of the implementation); it now states that
  `Spend` **is** emitted on every allowance-consuming `transferFrom`/`burnFrom` including infinite approvals, that
  `value` is the amount used rather than any reduction, that `forcedTransfer` now emits `Spend` on the reduction it
  performs (finite non-zero allowance only), and that integrators must read `allowance(owner, spender)` rather than
  accumulate `Spend`/`Approval` events.
- `doc/technical/allowance-spend-event.md` (new) — a cross-cutting reference covering the three emit sites, the
  ordering difference, the residual over-report on infinite approvals, the read-`allowance()` guidance, and a
  **"Possible improvement — making the emit sites consistent"** section describing the single-`_spendAllowance`
  unification (Option A above), its drawbacks, and why the `transferFrom`/`burnFrom` half is deferred. Linked from
  the README technical index.
- Tests — `test/common/ERC20EnforcementModuleCommon.js`: the two allowance-reducing `forcedTransfer` tests now
  assert the `Spend` amount (full and partial consumption), plus two new tests asserting **no** `Spend` when there
  is no allowance and when the allowance is infinite.

Only the `forcedTransfer` under-report was closed in behaviour; the remaining `transferFrom`/`burnFrom`
inconsistencies (ordering, emission on infinite approvals) stay documentation-only, recorded in the technical doc
as a possible future improvement rather than scheduled work.

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

**All actionable items have been resolved. No item remains open.** The four defects and the reentrancy cluster
were fixed in code where warranted; the rest were documented. Summary:

1. **NM-15 / NM-17 — `_setFrozenTokens` missing the zero-address guard** (`ERC20EnforcementModuleInternal.sol`).
   An `ERC20ENFORCER_ROLE` holder could halt all minting protocol-wide with one call. **FIXED** — guard added
   (matching the sibling functions), 5 regression tests; the pre-existing test that pinned the bug under a
   misleading name was removed.
2. **NM-3 / NM-8 — allowance revocation blocked while paused or restricted** (`ValidationModuleAllowance.sol` +
   4 call sites). **FIXED** — `value == 0` is always authorized; non-zero grants remain gated exactly as before
   (7 regression tests, two of them negative guards).
3. **NM-24 — `Spend` event contradicts its NatSpec, and `forcedTransfer` consumed allowance silently.** **FIXED** —
   the `IERC20Allowance.Spend` NatSpec was corrected, and `_forcedTransfer` now emits `Spend` on the allowance
   reduction (4 regression tests). The residual `transferFrom`/`burnFrom` cosmetic inconsistency is documented in
   `doc/technical/allowance-spend-event.md` as an optional future improvement.
4. **NM-22 — ERC-7551 `setTerms` overload wiped the terms document name.** **FIXED** — name-preserving overload
   (`_setTermsDocument`), 1 regression test; the test that pinned the erasure was corrected.
5. **NM-7 / NM-9 / NM-11 / NM-16 / NM-18 — RuleEngine callback reentrancy.** **FIXED where it fits** — the external
   callback is isolated in a `virtual` `_callRuleEngineTransferred`, wrapped in OpenZeppelin's
   `ReentrancyGuardTransient` (`nonReentrant`) on the deployment variants with bytecode headroom (Standard,
   Snapshot, ERC-7551). The variants without headroom stay unguarded **by design**, and the trust assumption (the
   `DEFAULT_ADMIN_ROLE`-set RuleEngine must not hand control to untrusted code) is now documented with a
   per-variant table in
   [`doc/modules/controllers/validationRuleEngine.md`](../../../../modules/controllers/validationRuleEngine.md).
   Malicious-engine mock + 7 regression tests.

**The NM-5 documentation follow-up is also resolved.** `doc/technical/access-control.md` previously claimed a
frozen operator cannot mint. Probing showed the opposite — CMTAT's own freeze checks the recipient, not the
operator, so a frozen `MINTER_ROLE` holder mints successfully (a configured RuleEngine may still reject via the
spender it receives; the Light variant has no RuleEngine). The behaviour is intended and unchanged; the
documentation was corrected across `access-control.md` (with a per-operation/per-deployment table), `doc/README.md`,
`ERC20Mint.md` and `cross-chain-bridge-integration.md`, and locked in by tests (`testFrozenMinterCanStillMint` /
`…BatchMint`, verified on Standard, Light and Allowlist; `testMintPropagatesSpenderToRuleEngine` for the RuleEngine
rejection path). The Light `_minterTransferOverride` was additionally aligned to pass `_msgSender()` (behaviour-
neutral).
