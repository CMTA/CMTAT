# Wake Arena AI Report – CMTAT v3.2.0-rc2 — Feedback

**Report date:** February 10, 2026
**Auditor:** Ackee Blockchain Security (Wake Arena AI tool)
**Response date:** February 20, 2026
**Reviewed commits:**
- `0635d82` – "Wake: remove redundant call"
- `8a18c94` – "Wake-L1: add comment"
- `22eb88c` – "Wake-l1: fix documentation mismatch"

[TOC]



---

## Findings Summary

| ID | Title | Impact | Status |
|----|-------|--------|--------|
| M1 | Double invocation of compliance hook in `_minterTransferOverride` | Medium | Fixed |
| M2 | Double invocation of compliance hook in `_burnOverride` | Medium | Fixed |
| M3 | Double invocation of compliance hook in `_mintOverride` | Medium | Fixed |
| L1 | Misleading `Spend` event when allowance is infinite | Low | Acknowledged (comment added) |
| L2 | Unmitigated ERC20 `approve` allowance change race condition | Low | Acknowledged – won't fix |
| I1 | Documentation mismatch in `_authorizeSelfBurn` | Info | Fixed |

---



## M1 / M2 / M3 – Double invocation of rule-engine compliance hook

**Finding:** `CMTATBaseERC20CrossChain._mintOverride`, `_burnOverride`, and `_minterTransferOverride` each called `CMTATBaseRuleEngine._checkTransferred` directly before delegating to the corresponding `CMTATBaseCommon` override, which itself calls `_checkTransferred` again. This caused the external `IRuleEngine.transferred` hook to execute twice per operation, potentially double-charging quotas, skewing counters, or causing avoidable reverts.

**Fix (commit `0635d82`):** The redundant direct calls to `CMTATBaseRuleEngine._checkTransferred` were removed from all three overrides. The single authoritative call now originates exclusively from the `CMTATBaseCommon` parent overrides.

**Assessment: Fix is correct and sufficient.**

One minor note: the comment added in `_mintOverride` contains a typo (`_minzOverride` instead of `_mintOverride`). It is harmless but worth correcting for clarity.

```solidity
// _checkTransferred is called by _minzOverride  ← typo: should be _mintOverride
CMTATBaseCommon._mintOverride(account, value);
```

---

## L1 – Misleading `Spend` event when allowance is infinite

**Finding:** `ERC20BaseModule.transferFrom` unconditionally emits `Spend(from, _msgSender(), value)` even when the allowance is `type(uint256).max`. In the infinite-approval case OpenZeppelin deliberately skips the allowance decrement, so the emitted event implies a reduction that never occurred, potentially misleading off-chain indexers.

**Fix (commit `8a18c94`):** A clarifying comment was added directly above the `emit Spend` statement:

```solidity
// emit Spend does not necessarily imply an allowance reduction
// This is the case if the allowance is set to uint256.max
emit Spend(from, _msgSender(), value);
```

**Assessment: Acknowledged via documentation; behavior unchanged.**

The chosen approach corresponds to option 3 from the report's recommendation ("update the interface and downstream documentation to clarify that `Spend` does not necessarily imply an allowance reduction"). The report itself notes this option is discouraged because it deviates from the current stated contract of the event.

The comment improves developer awareness but does not resolve the log/state divergence for off-chain consumers. If downstream integrators rely on `Spend` as the source of truth for allowance deltas, they will still see incorrect reductions when infinite allowances are used.

A clarifying note has been added to the `Spend` event definition in `IERC20Allowance.sol` to warn integrators that this event is not emitted when the allowance is infinite (`type(uint256).max`) and that they must not rely solely on it to track allowance changes when infinite approvals are in use.

---

## L2 – Unmitigated ERC20 `approve` allowance change race condition

**Finding:** `CMTATBaseAllowlist.approve` does not enforce a zero-first update pattern. A spender can front-run an allowance change to consume both the old and the new allowance.

**Assessment: Acknowledged – no code change planned.**

This is the well-known ERC-20 allowance race condition that exists in the standard itself. The broader ecosystem has largely concluded that it is not worth mitigating at the contract level, for several reasons discussed in [OpenZeppelin/openzeppelin-contracts#4583](https://github.com/OpenZeppelin/openzeppelin-contracts/issues/4583):

- **Rarely exploited in practice.** An open bounty of 1500+ DAI was offered to demonstrate the race condition had ever been triggered in the wild; it was never claimed.
- **`increaseAllowance` / `decreaseAllowance` are not a safe substitute.** OpenZeppelin removed both functions from the base ERC20 contract in v5.0.0. `decreaseAllowance` is itself vulnerable to frontrunning and does not fully solve the race; `increaseAllowance` was involved in a $24M phishing loss via a malicious signature, expanding the attack surface rather than reducing it.
- **Non-standard helpers introduce new risks.** Functions outside EIP-20 can bypass spending-limit protections in smart wallets (e.g., Argent) that filter only for standard `transfer`/`approve` calls.

In the context of CMTAT, which is also used as a library, we decided to follow the same principle as OpenZeppelin and not mitigate this at the contract level.

A warning has been added to the `approve` NatSpec in `contracts/modules/2_CMTATBaseAllowlist.sol` documenting the standard ERC-20 race risk and advising callers to set the allowance to zero before assigning a new value if strict control over the total spendable amount is required.

---

## I1 – Documentation mismatch in `_authorizeSelfBurn`

**Finding:** The NatSpec comment for `CMTATBaseERC20CrossChain._authorizeSelfBurn` states the caller must hold `BURNER_FROM_ROLE`, while the implementation enforces `BURNER_SELF_ROLE` via `onlyRole(BURNER_SELF_ROLE)`.

**Assessment: Fixed.**

The NatSpec comment above `_authorizeSelfBurn` was a copy-paste from `_authorizeBurnFrom` and incorrectly referenced `BURNER_FROM_ROLE`. The comment has been corrected to reference `BURNER_SELF_ROLE`, which matches the `onlyRole(BURNER_SELF_ROLE)` modifier enforced by the implementation.

---

## Overall Assessment

The two medium-severity findings (M1/M2/M3, treated as a single cluster) were the most impactful and have been correctly fixed. The redundant `_checkTransferred` path is eliminated, restoring correct single-execution semantics for the rule engine hook across mint, burn, and minter-transfer operations.

L1 is partially mitigated via documentation. L2 is acknowledged as a known ERC-20 limitation that the broader ecosystem (including OpenZeppelin v5) has chosen not to address at the contract level. I1 has been fixed by correcting the NatSpec comment in `_authorizeSelfBurn`.
