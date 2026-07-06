# ERC-1450 (RTA-Controlled Security Token) — CMTAT Integration

> [ERC specification](./../ERCSpecification/erc-1450.md) — *RTA-Controlled Security Token*
>
> Status: Last Call (last-call-deadline 2026-07-14) · `requires: 20, 165, 6093`

## Overview

ERC-1450 describes a **US-securities-law** token model where a single **Registered
Transfer Agent (RTA)** holds *exclusive* authority over every token movement. Holders
can never move value themselves: `transfer()` and `approve()` always revert, and the
only value paths are RTA-executed `transferFromRegulated` / `controllerTransfer`, or a
holder/broker-*requested* transfer (`requestTransferWithFee`) that still needs RTA
execution.

CMTAT and ERC-1450 target the same problem (compliant tokenized securities) from two
different philosophies:

| Axis | ERC-1450 | CMTAT |
|---|---|---|
| Authority | Single **RTA** controls everything | **Role-based** (`MINTER_ROLE`, `BURNER_ROLE`, `ENFORCER_ROLE`, `DEFAULT_ADMIN_ROLE`, …) |
| Peer transfers | **Disabled** (`transfer`/`approve` revert) | **Allowed but gated** by `ValidationModule` / RuleEngine |
| Forced transfer | `controllerTransfer` (ERC-1644) | `forcedTransfer` (ERC-7943 / ERC-3643) in `ERC20EnforcementModule` |
| Compliance engine | Off-chain RTA + optional CCIP pre-check | On-chain RuleEngine / Allowlist |
| Documents | Embedded ERC-1643 subset | `DocumentERC1643Module` / `DocumentEngineModule` |
| Lot / regulation tracking | On-chain batches (`regulationType`, `issuanceDate`) | Not tracked on-chain |
| Fees / broker / request lifecycle | In-token | Absent |

**Bottom line:** CMTAT already provides the *enforcement* half of ERC-1450 (forced
transfer, freezing, pause, documents, snapshots) as reusable modules. What ERC-1450 adds
on top — the *RTA-exclusive* transfer policy, the on-chain **transfer-request lifecycle**,
the **fee/broker** system, and **per-lot regulation tracking** — is new surface that must
be built as a dedicated module. This document proposes a concrete integration.

---

## 1. Mapping ERC-1450 onto existing CMTAT modules

Most of the ERC-1450 *enforcement* surface maps directly onto shipping CMTAT modules.

| ERC-1450 requirement | CMTAT module / mechanism | Notes |
|---|---|---|
| `mint(to, amount, regulationType, issuanceDate)` | `ERC20MintModule` (`MINTER_ROLE`) | Base `mint`/`mintBatch` exist; regulation args need an extension (see §2). |
| `batchMint(...)` | `ERC20MintModule.mintBatch` | Same array semantics. |
| `burnFrom(from, amount)` | `ERC20BurnModule` (`BURNER_ROLE`) | ⚠ name collides with OZ `ERC20Burnable.burnFrom` (allowance-based) — see improvement doc. |
| `burnFromRegulated` / `burnFromRegulation` | `ERC20BurnModule` + regulation extension | Lot selection is new. |
| `transferFromRegulated(from,to,amount,…)` | `ERC20EnforcementModule.forcedTransfer` | RTA-executed transfer = CMTAT forced transfer. |
| `controllerTransfer(...)` (ERC-1644) | `ERC20EnforcementModule.forcedTransfer` | CMTAT emits ERC-7943 `ForcedTransfer`; add ERC-1644 `ControllerTransfer` alias if strict conformance is required. |
| `transfer` / `approve` MUST revert | `ValidationModule` / RuleEngine returning "no peer transfer" | CMTAT default *permits* gated transfers, so an RTA-controlled variant must additionally override `transfer`/`approve` to revert (see §3). |
| `setAccountFrozen` / `isAccountFrozen` | `EnforcementModule` (`ENFORCER_ROLE`) | Address-level freeze. |
| Partial token freeze | `ERC20EnforcementModule` (`setFrozenTokens` / `getFrozenTokens`) | Finer than ERC-1450 requires. |
| Regulatory halt | `PauseModule` (`PAUSER_ROLE`) | Global pause + optional deactivation. |
| `setDocument` / `getDocument` / `removeDocument` / `getAllDocuments` | `DocumentERC1643Module` (`DOCUMENT_ROLE`) **or** `DocumentEngineModule` (`DOCUMENT_ENGINE_ROLE`) | ERC-1643 — **ABI-compatible**, see §4 and the improvement doc. |
| Record dates / snapshots | `SnapshotEngineModule` (`SNAPSHOOTER_ROLE`) | Backs dividends, voting, quorum. |
| `changeIssuer` | RBAC admin transfer (`AccessControlDefaultAdminRules`) | "Issuer" ≈ CMTAT `DEFAULT_ADMIN_ROLE` holder. |
| `isKYCVerified` | RuleEngine / `ValidationModuleAllowlist` (`ALLOWLIST_ROLE`) | On-chain allowlist or external KYC oracle. |
| `version()` | `VersionModule` | Already present. |
| `isSecurityToken()` | new `pure` returning `true` | Trivial add. |
| Recovery workflow | `forcedTransfer` + `DocumentEngineModule` evidence anchoring | Structured/time-locked flow is new (see §2). |
| RTAProxy (REQUIRED multisig) | External Safe / multisig holding the CMTAT roles | CMTAT does not need a bespoke proxy; a Safe granted the admin + operational roles satisfies the "RTA multisig" requirement. |

### Role model: how one "RTA" maps to CMTAT roles

ERC-1450 concentrates authority in one RTA address (an `RTAProxy` multisig). In CMTAT the
equivalent is a **single multisig (Safe) granted the full operational role set**:

```
RTAProxy (Safe, M-of-N)  ─ granted ─▶ DEFAULT_ADMIN_ROLE   (changeIssuer, role admin)
                                      MINTER_ROLE           (mint / batchMint)
                                      BURNER_ROLE           (burnFrom*)
                                      ENFORCER_ROLE         (forcedTransfer, freeze)
                                      PAUSER_ROLE           (regulatory halt)
                                      DOCUMENT_ROLE         (ERC-1643 documents)
                                      SNAPSHOOTER_ROLE      (record dates)
```

This preserves ERC-1450's "one controller" semantics while keeping CMTAT's ability to
*delegate* individual roles later (e.g. hand `DOCUMENT_ROLE` to the issuer, which ERC-1450
explicitly allows: "the issuer maintains rights to update corporate documents").

---

## 2. New surface CMTAT must add

Four ERC-1450 capabilities have **no CMTAT equivalent** and would be delivered as one new
optional module (proposed: `ERC1450RequestModule`) plus a small mint/burn extension. Keep
module numbering consistent with the dependency ordering rule in `CLAUDE.md` — this module
depends on core + enforcement + document layers, so it sits above `ValidationModule`.

1. **Transfer-request lifecycle** — `requestTransferWithFee`, `processTransferRequest`,
   `rejectTransferRequest`, `updateRequestStatus`, `getRequestStatus`, the
   `RequestStatus` state machine, and the `TransferRequested` / `RequestStatusChanged` /
   `TransferExecuted` / `TransferRejected` / `TransferExpired` events.
   *Execution* delegates to `ERC20EnforcementModule.forcedTransfer`.

2. **Fee system** — `setFeeToken`, `setFeeParameters`, `getTransferFee`, `withdrawFees`,
   `requestTransferWithPermit`. Fee token is an external ERC-20 (e.g. USDC); collection uses
   `safeTransferFrom` on the *fee token* (not the security token).

3. **Broker registry** — `setBrokerStatus`, `isRegisteredBroker`, gating who may call
   `requestTransferWithFee` on behalf of a holder. Maps naturally to a new
   `BROKER_ROLE` under CMTAT AccessControl.

4. **Per-lot regulation tracking** — `getHolderRegulations`, `getRegulationSupply`,
   `getDetailedBatchInfo`, plus the `regulationType` / `issuanceDate` parameters threaded
   through mint/burn/transfer and the `TokensMinted` / `TokensBurned` / `RegulatedTransfer`
   events. Storage pattern: `mapping(address => TokenBatch[])` as in the ERC's
   non-normative guidance.

> ⚠ On-chain lot tracking is heavyweight and, per the ERC itself, the RTA already keeps the
> authoritative cap table off-chain. Treat item (4) as **optional** — see the improvement
> doc for why it may be better emitted as events only rather than stored.

---

## 3. Proposed deployment variant

Rather than fork the core, add an RTA-controlled deployment variant that composes existing
modules and the new request module:

```
CMTATBaseCommon (ERC20 + Mint + Burn + ERC20Enforcement)
   ↓
CMTATBaseDocument            (ERC-1643)
   ↓
CMTATBaseAccessControl       (RBAC → the "RTA" role bundle)
   ↓
CMTATBaseRuleEngine          (RuleEngine that REJECTS all peer transfers)
   ↓
ERC1450RequestModule (new)   (request lifecycle + fee + broker + regulation)
   ↓
CMTATRTAControlled (deployment)  →  overrides transfer()/approve() to revert,
                                    isSecurityToken()=true,
                                    supportsInterface(IERC1450)=true
```

The **RTA-exclusive** property is achieved two ways in combination:
- A RuleEngine (or a dedicated `ValidationModuleRTA`) that denies every non-forced transfer, and
- Overriding `transfer` / `approve` / `transferFrom` to revert with `ERC1450TransferDisabled()`, so the token is behaviorally (not just policy-) locked.

### ERC-165 note (behavioral, not just ABI)

ERC-1450 requires `supportsInterface`:
- MUST return `true` for `0xaf175dee` (IERC1450) and `0x01ffc9a7` (ERC-165),
- **MUST return `false` for `0x36372b07` (ERC-20)** — because `transfer`/`approve` revert.

This conflicts with a normal CMTAT deployment, which *is* behaviorally ERC-20. The
RTA-controlled variant must therefore deliberately **not** advertise the ERC-20 interface
ID. This is the single biggest semantic divergence and must be a conscious variant choice,
not a default.

---

## 4. ERC-1643 documents — reuse CMTAT's module as-is

ERC-1450 embeds an ERC-1643 document subset (`setDocument`, `getDocument`,
`removeDocument`, `getAllDocuments`, `DocumentUpdated`, `DocumentRemoved`). CMTAT's
`DocumentERC1643Module` already implements exactly this interface and is **ABI/selector
compatible** with the ERC-1450 subset (CMTAT returns a `Document` struct from
`getDocument`, which encodes identically to the ERC-1450 `(string, bytes32, uint256)`
tuple). So the CMTAT document module backs ERC-1450's document functions with **no change**.

The full compatibility analysis (ERC-1450's document subset vs. the *updated* ERC-1643) is
in [`erc-1450-improvement.md`](./erc-1450-improvement.md#erc-1643-compatibility) — short
version: **compatible**, with a few `SHOULD`-level error/no-revert semantics to adopt.

---

## 5. Integration checklist

- [ ] Deploy an `RTAProxy` Safe; grant it the RTA role bundle (§1).
- [ ] Deploy `CMTATRTAControlled` variant with `transfer`/`approve` reverting.
- [ ] Configure a RuleEngine (or `ValidationModuleRTA`) that denies peer transfers.
- [ ] Wire `transferFromRegulated` / `controllerTransfer` → `forcedTransfer`.
- [ ] Add `ERC1450RequestModule` for request lifecycle + fee + broker (+ optional regulation lots).
- [ ] Reuse `DocumentERC1643Module` for documents; `SnapshotEngineModule` for record dates.
- [ ] Set `supportsInterface`: `true` for IERC1450, `false` for ERC-20.
- [ ] Map allowlist/KYC to `ValidationModuleAllowlist` or an external KYC RuleEngine.

---

## Related documents

- [`ruleengine-integration.md`](./ruleengine-integration.md) — validation / spender semantics
- [`erc-7943-uRWA-integration.md`](./erc-7943-uRWA-integration.md) — forced transfer & freezing
- [`erc-1450-improvement.md`](./erc-1450-improvement.md) — spec critique + ERC-1643 compatibility
