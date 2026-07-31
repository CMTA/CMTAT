# The `Spend` allowance event

CMTAT emits a custom `IERC20Allowance.Spend(account, spender, value)` event whenever a spender consumes an owner's
allowance. It complements the standard ERC-20 `Approval` event (which signals *granting* an allowance) by signalling
its *consumption*.

```solidity
event Spend(address indexed account, address indexed spender, uint256 value);
```

## Where it is emitted

There are two emit sites, and they behave slightly differently.

| | `transferFrom` (`ERC20BaseModule`) | `burnFrom` (`ERC20CrossChainModule`) | `forcedTransfer` (`ERC20EnforcementModule`) |
| --- | --- | --- | --- |
| Available on | every variant with an allowance surface | cross-chain variants only | every variant with enforcement |
| Allowance spent by | `ERC20Upgradeable.transferFrom` (internally) | an explicit `_spendAllowance(...)` | manual `_approve(from, to, reduced, false)` |
| `Spend` emitted | **after** the transfer completes | **between** `_spendAllowance` and the burn | when a finite non-zero `from`→`to` allowance is reduced |
| Event order in the receipt | `Transfer` → `Spend` | `Spend` → `Transfer` → `BurnFrom` | `Spend` → `Transfer` → `ForcedTransfer` |

The self-burn `burn(uint256)` emits **no** `Spend` — it consumes no allowance.

## What `Spend` does and does not tell you

- **It does not imply the allowance decreased.** On `transferFrom` / `burnFrom`, `Spend` is emitted on every
  successful call, including when the allowance is infinite (`type(uint256).max`), where OpenZeppelin leaves the
  allowance unchanged. `value` is the amount *used*, not the size of any reduction.
- **`forcedTransfer` emits `Spend` only when it actually reduces the allowance** — i.e. when the `from`→`to`
  allowance is finite and non-zero. `value` is then the amount taken from it (capped by the allowance). It does
  **not** emit `Approval` for that reduction, so `Spend` is the only signal of it.

Net effect for an integrator that reconstructs allowances purely from events: the figure still drifts **too low**
after an infinite-approval `transferFrom`/`burnFrom` (a `Spend` with no matching reduction). The former
`forcedTransfer` *under*-report is gone — the reduction now emits `Spend`.

> **Guidance.** To obtain a spender's current allowance, always read `allowance(owner, spender)` on-chain. Never
> accumulate `Spend` (or `Approval`) events as a substitute — the infinite-allowance case alone makes event-summing
> wrong.

## Possible improvement — making the emit sites consistent

`forcedTransfer` now emits `Spend` when it reduces a finite allowance, so it is no longer a silent consumer. The
two remaining `transferFrom` / `burnFrom` sites are consistent enough to be usable but not identical: they differ
in event ordering, and both emit even on infinite approvals (which the older `IERC20Allowance` NatSpec incorrectly
claimed they did not — that NatSpec has been corrected). A future release could unify them. This is **not planned**
and would be a behaviour change, so it is recorded here as an option rather than a commitment.

The cleanest unification emits `Spend` from a single overridden `_spendAllowance`, through which **both** paths
already route their allowance spend:

```solidity
function _spendAllowance(address owner, address spender, uint256 value) internal virtual override {
    if (allowance(owner, spender) != type(uint256).max) {
        emit IERC20Allowance.Spend(owner, spender, value);
    }
    super._spendAllowance(owner, spender, value);
}
```

with the two explicit `emit Spend` statements removed. This would give one emit site, one ordering
(`Spend` → `Transfer` on both paths), and would make the event actually skip the infinite-allowance case.

**Drawbacks — why it is not applied:**

- It is an **observable behaviour change**: `Spend` would stop firing for infinite-allowance spends, and the
  `transferFrom` order would flip from `Transfer → Spend` to `Spend → Transfer`. Any indexer keyed on either
  breaks, so it belongs in a **major version**, not a patch.
- The `allowance(...)` read in the override is an **extra `SLOAD` on every `transferFrom`** — the hottest path in
  the token — unless `_spendAllowance` is fully re-implemented to reuse the value it already loads, which means
  diverging from the audited OpenZeppelin body.
- Several deployment variants are within a few hundred bytes of the EIP-170 24 KiB limit, so even a small net
  addition must be measured before it can ship.

A cheaper, ordering-only variant (moving `burnFrom`'s `emit Spend` to after the burn so `Spend` is last on both
paths) aligns the receipts but leaves the infinite-allowance emission untouched, so it does not remove the
substantive inconsistency and is not worth a breaking change on its own.

**Current position:** `forcedTransfer` now emits `Spend` on the allowance reduction (so its former under-report is
closed); the `transferFrom`/`burnFrom` unification remains documentation-only. The `IERC20Allowance.Spend` NatSpec
has been corrected to describe the real behaviour, and the guidance above (read `allowance()`, do not sum events)
is the durable fix for integrators.

> Origin: Nethermind AuditAgent v3.3.0-rc2 finding NM-24. See the
> [maintainer feedback](../security/tools/nethermind-audit-agent/v3.3.0-rc2/audit_agent_report_v3.3.0-rc2-feedback.md).
