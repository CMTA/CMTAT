---
eip: 8300
title: Fungible Token Holder Enumeration
description: An interface for enumerating the addresses that hold a non-zero balance of a fungible token, without an on-chain identity registry.
author: Ryan Sauge (@ryansauge)
discussions-to: https://ethereum-magicians.org/t/erc-8300-fungible-token-holder-enumeration/00000
status: Draft
type: Standards Track
category: ERC
created: 2026-07-09
requires: 20, 165
---

## Abstract

This ERC proposes an optional extension for [ERC-20](./eip-20.md) tokens that exposes the set of addresses currently holding a non-zero balance. It defines five view functions — `holderCount`, `holderByIndex`, `isHolder`, `holders`, and `holdersInRange` — that allow the complete holder set to be enumerated one entry at a time, mirroring the accessor shape established by the [ERC-721](./eip-721.md) enumeration extension; in a single call returning the whole set; or in caller-bounded windows by index range.

It also defines two OPTIONAL events, `HolderAdded` and `HolderRemoved`, which an implementation MAY emit when an address enters or leaves the holder set, so that an indexer can track the set incrementally without replaying the transfer log.

The extension is a pure view over `balanceOf`. It introduces no independent state that could disagree with the token's balances, no identity registry, no allowlist, and no transfer restrictions. It adopts [ERC-165](./eip-165.md) for introspection.

## Motivation

[ERC-20](./eip-20.md) stores balances in a `mapping(address => uint256)`. Solidity mappings carry no key set: there is no length, no iteration, and no way to ask which addresses have a non-zero value. Consequently a token contract cannot answer, on-chain, the question *"who holds this token?"* — a question that arises in three recurring contexts:

- **Regulated instruments.** Corporate law may oblige an issuer to produce a register of holders on demand. [ERC-884](./eip-884.md) established `holderCount` / `holderAt` / `isHolder` for exactly this reason, but bundled them with a mandatory identity-verification gate, `decimals() == 0`, and a prohibition on transfers to unverified addresses. An issuer who wants only the register must adopt the entire compliance apparatus.
- **Supply-bounded tokens.** Vault shares, LP receipts, membership tokens, and DAO shares frequently have a naturally small and often permissioned holder set. Their integrators repeatedly reimplement holder tracking with ad-hoc, non-interoperable interfaces.
- **Tooling.** Wallets, explorers, and auditors reconstruct holder sets by replaying `Transfer` logs. This is correct and cheap, but it requires an archive node or a third-party indexer, and it cannot be performed by a contract or by a light client.

Existing standards do not fill this gap:

- [ERC-721](./eip-721.md)'s enumeration extension returns `uint256` token identifiers, never addresses. `tokenOfOwnerByIndex` takes the owner as an *input*. Its holder set is only recoverable by composing `tokenByIndex` with `ownerOf` and deduplicating — an inversion that fungible tokens structurally lack, because a balance has no identity to invert. This is the reason a fungible analogue must be specified separately rather than adapted.
- [ERC-5805](./eip-5805.md) checkpoints voting weight per address, but every accessor is a point query taking an `address` argument. It answers *how much* a known address controlled at a past timepoint, never *which* addresses exist.
- [ERC-3643](./eip-3643.md) maintains a registry of addresses *permitted to hold*, which is a distinct set from those *currently holding*, and mandates a full compliance stack to obtain it.

This ERC extracts the enumeration primitive from ERC-884 and states it independently of any compliance mechanism, so that it can be adopted by permissioned and permissionless tokens alike, and so that integrators have one interface to detect via [ERC-165](./eip-165.md) rather than several.

The standard deliberately does not attempt to make on-chain iteration safe. It cannot: on a freely transferable token the holder set is unbounded and adversarially inflatable. See [Security Considerations](#security-considerations).

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

An [ERC-8300](./eip-8300.md) contract MUST implement [ERC-20](./eip-20.md) and MUST implement [ERC-165](./eip-165.md).

```solidity
/// @notice Holder enumeration extension for ERC-20 tokens.
interface IERC8300 is IERC165 {
    /// @notice Error reverted when an index is greater than or equal to the number of holders.
    /// @param index The index that was requested.
    /// @param count The current number of holders, i.e. the exclusive upper bound.
    error ERC8300OutOfBoundsIndex(uint256 index, uint256 count);

    /// @notice Error reverted when a range is malformed because its lower bound exceeds its
    /// upper bound. This is distinct from `ERC8300OutOfBoundsIndex`: the range is not past the
    /// end of the set, it is internally inconsistent, so neither argument is a holder count.
    /// @param fromIndex The requested lower bound, inclusive.
    /// @param toIndex The requested upper bound, exclusive.
    error ERC8300InvalidRange(uint256 fromIndex, uint256 toIndex);

    /// @notice OPTIONAL. Emitted when an address enters the holder set, i.e. when its balance
    /// transitions from zero to non-zero. See the Events section for the emission rules.
    /// @param holder The address that entered the holder set.
    event HolderAdded(address indexed holder);

    /// @notice OPTIONAL. Emitted when an address leaves the holder set, i.e. when its balance
    /// transitions from non-zero to zero. See the Events section for the emission rules.
    /// @param holder The address that left the holder set.
    event HolderRemoved(address indexed holder);

    /// @notice Counts the addresses that currently hold a non-zero balance.
    /// @return count The number of unique addresses `a` for which `balanceOf(a) > 0`.
    function holderCount() external view returns (uint256 count);

    /// @notice Enumerates holders.
    /// @dev Reverts with `ERC8300OutOfBoundsIndex` if `index >= holderCount()`.
    /// The sort order is not specified, and the index of a given holder is not stable
    /// across state changes. Callers MUST NOT persist an index as a reference to a holder.
    /// @param index A counter less than `holderCount()`.
    /// @return holder The address of the `index`th holder.
    function holderByIndex(uint256 index) external view returns (address holder);

    /// @notice Checks whether an address currently holds a non-zero balance.
    /// @param account The address to check.
    /// @return holding True if `balanceOf(account) > 0`, false otherwise.
    function isHolder(address account) external view returns (bool holding);

    /// @notice Returns the complete holder set in a single call.
    /// @dev The returned length equals `holderCount()`. The holder set is unbounded and
    /// adversarially inflatable, so this call is intended for `eth_call` and MUST NOT be
    /// invoked by an on-chain caller. See Security Considerations.
    /// @return allHolders Every address `a` for which `balanceOf(a) > 0`, each exactly once.
    function holders() external view returns (address[] memory allHolders);

    /// @notice Returns a contiguous window of the holder set by index range.
    /// @dev Returns the holders at indices `[fromIndex, toIndex)` — `fromIndex` inclusive,
    /// `toIndex` exclusive — so the returned length is `toIndex - fromIndex`. The window is a
    /// slice of the same sequence `holderByIndex` enumerates: `holdersInRange(f, t)[i]` equals
    /// `holderByIndex(f + i)`. Reverts with `ERC8300OutOfBoundsIndex` if `toIndex > holderCount()`,
    /// or with `ERC8300InvalidRange` if `fromIndex > toIndex`. Callers reading a set too large for `holders()` walk it in
    /// caller-sized windows; each window is atomic within a single `eth_call`, but coherence
    /// across windows requires pinning every call to the same block. See Security Considerations.
    /// @param fromIndex The index of the first holder to return, inclusive.
    /// @param toIndex The index one past the last holder to return, exclusive.
    /// @return window The holders at indices `fromIndex` through `toIndex - 1`, in enumeration order.
    function holdersInRange(uint256 fromIndex, uint256 toIndex) external view returns (address[] memory window);
}
```

### The holder set

The **holder set** `H` is defined in terms of the token's own `balanceOf`:

```
H = { a : balanceOf(a) > 0 }
```

This definition is normative and total. The five functions are views over `H` and nothing else:

```
isHolder(a)          ⟺  a ∈ H
holderCount()        ==  |H|
{ holderByIndex(i) : 0 ≤ i < holderCount() }  ==  H
holders()            ==  [ holderByIndex(0), …, holderByIndex(holderCount() - 1) ]
holdersInRange(f, t) ==  [ holderByIndex(f), …, holderByIndex(t - 1) ]
```

The third property requires `holderByIndex` to be injective over the valid index range, so enumeration visits each holder exactly once with no repeats and no gaps.

The fourth and fifth properties are equalities of sequences, not merely of sets: within a single block, `holders()[i]` MUST equal `holderByIndex(i)` for every `i` in `[0, holderCount())`, and `holdersInRange(f, t)[i]` MUST equal `holderByIndex(f + i)` for every `i` in `[0, t - f)`. All three accessors therefore agree on order as well as on membership, and `holders()` is exactly `holdersInRange(0, holderCount())`. A caller may substitute one for another freely within a block. Across blocks none of the orderings is stable.

Implementations MUST maintain these properties across **every** operation that changes a balance, including but not limited to `transfer`, `transferFrom`, minting, burning, and any privileged or enforcement transfer such as [ERC-7943](./eip-7943.md)'s `forcedTransfer`. Specifically:

- When `balanceOf(a)` transitions from zero to non-zero, `a` MUST be inserted into `H`.
- When `balanceOf(a)` transitions from non-zero to zero, `a` MUST be removed from `H`.
- A transfer of zero tokens MUST NOT alter `H`.

### `holderCount`

Returns `|H|`. This function:

- MUST NOT revert.
- MUST NOT change the storage of the contract.
- MUST return `0` when no address holds a non-zero balance, including when `totalSupply()` is `0`.
- MUST NOT be assumed by callers to bear any relationship to `totalSupply()`.

### `holderByIndex`

Returns the holder stored at `index`. This function:

- MUST revert with `ERC8300OutOfBoundsIndex` if `index >= holderCount()`.
- MUST NOT change the storage of the contract.
- MUST NOT return the same address for two distinct indices in `[0, holderCount())` observed within a single block.
- MUST NOT return an address `a` for which `balanceOf(a) == 0`.
- MAY return a different address for the same `index` after any state change. The ordering is an implementation detail and is explicitly NOT part of this standard.

### `isHolder`

Returns whether `account` belongs to `H`. This function:

- MUST NOT revert, including when `account` is the zero address.
- MUST NOT change the storage of the contract.
- MUST return `true` if and only if `balanceOf(account) > 0`. In particular, `isHolder(a)` MUST NOT return `false` for an address with a non-zero balance that was acquired through a privileged or non-standard mint path.

### `holders`

Returns `H` in full. This function:

- MUST return an array of length exactly `holderCount()`.
- MUST contain every member of `H` exactly once, with no repeats and no zero-address padding.
- MUST agree with `holderByIndex` on ordering within a single block, as stated above.
- MUST NOT change the storage of the contract.
- MUST return an empty array when `H` is empty, and MUST NOT revert in that case.
- MUST NOT be relied upon by an on-chain caller. The array is unbounded, its memory-expansion cost grows quadratically in `|H|`, and `H` is attacker-inflatable on a freely transferable token. An implementation cannot cap the length without violating the first bullet, and so a sufficiently large `H` renders this function uncallable within any finite gas limit. It is intended for `eth_call`, where the provider's own gas cap is the only bound.

An implementation that cannot satisfy the length requirement for its expected `H` — because it anticipates a holder set too large to return — SHOULD NOT claim support for this interface via [ERC-165](./eip-165.md). Where the obstacle is only the size of a single `holders()` response, such an implementation MAY still serve callers through `holderByIndex` and `holdersInRange`, which the caller can bound.

### `holdersInRange`

Returns the contiguous window of holders at indices `[fromIndex, toIndex)`. This function:

- MUST revert with `ERC8300OutOfBoundsIndex(toIndex, holderCount())` if `toIndex > holderCount()`. The `count` parameter of the error MUST carry the current `holderCount()`, so a caller that raced a concurrent removal learns the new bound from the revert data. This is the same out-of-bounds condition, and the same error, as `holderByIndex`.
- MUST revert with `ERC8300InvalidRange(fromIndex, toIndex)` if `fromIndex > toIndex`. This is a distinct failure from the one above: the range is malformed rather than out of bounds, and `ERC8300OutOfBoundsIndex` MUST NOT be used for it, because that error's second parameter is defined as the holder count and `toIndex` is not a holder count. The check on `fromIndex > toIndex` MUST be evaluated before the check on `toIndex > holderCount()`, so a caller that supplies an inverted range receives `ERC8300InvalidRange` regardless of where the bounds fall.
- MUST return an empty array, and MUST NOT revert, when `fromIndex == toIndex` — including when both equal `holderCount()`, which is the natural terminating condition of a paging loop.
- MUST return an array of length exactly `toIndex - fromIndex`.
- MUST return, at position `i`, the address `holderByIndex(fromIndex + i)`, so the window is a slice of the enumeration sequence and agrees with `holderByIndex` and `holders()` on order within a single block.
- MUST NOT change the storage of the contract.
- MAY return different addresses for the same `(fromIndex, toIndex)` after any state change, since the underlying ordering is not stable. A caller reassembling the full set from several windows MUST pin every call to the same block, exactly as it would for a `holderByIndex` loop; otherwise a concurrent removal may cause it to skip or duplicate a holder across the window boundary. See [Security Considerations](#security-considerations).

`holdersInRange` is bounded by the caller's own arguments, so unlike `holders()` it can serve a holder set larger than a single unbounded response would allow, at the cost of one call per window. It is nonetheless subject to the same on-chain hazard as the other enumerating accessors when the requested range is large: a contract that calls it with an attacker-influenced range inherits an attacker-influenced cost.

### Events

A conforming contract MAY declare and emit `HolderAdded` and `HolderRemoved`. They are OPTIONAL: an implementation that omits them entirely remains fully conforming, and their presence or absence does not change the [ERC-165](./eip-165.md) identifier, which is derived from function selectors alone.

An implementation that emits them MUST emit them on the transitions of `H`, and not on the balance changes that merely occasion those transitions:

- MUST emit `HolderAdded(a)` when `balanceOf(a)` transitions from zero to non-zero — exactly when `a` enters `H`.
- MUST emit `HolderRemoved(a)` when `balanceOf(a)` transitions from non-zero to zero — exactly when `a` leaves `H`.
- MUST NOT emit either event for a balance change that does not cross zero. A transfer between two addresses that both already hold, a mint to an existing holder, a partial burn, and a transfer of zero tokens all leave `H` unchanged and MUST be silent.
- MUST NOT emit either event for `address(0)`, unless `address(0)` is itself a member of `H` under [The zero address](#the-zero-address) below, in which case it is an ordinary member and the rules above apply to it unmodified.
- MUST emit the event in the same transaction as the transition it reports, and MUST have brought `H` into agreement with `balanceOf` before making any external call, per [Security Considerations](#security-considerations).

An address MAY enter and leave `H` any number of times, and each crossing MUST be reported. The events are transition markers, not a once-per-address lifecycle: an address that is drained and later credited again emits a second `HolderAdded`, and an address that is credited and then fully drained within a single transaction emits `HolderAdded` followed by `HolderRemoved`, in that order.

The emission rules exist to preserve one property, on which any incremental consumer depends:

```
holderCount() at block N  ==  ( total HolderAdded emitted up to and including N )
                            − ( total HolderRemoved emitted up to and including N )
```

An implementation that emits MUST do so uniformly across every balance-mutating path — including minting, burning, and any privileged or enforcement transfer. A log that covers some transitions but not others is worse than no log at all, because it is indistinguishable from a complete one.

### The zero address

The invariant is stated purely in terms of `balanceOf` and therefore admits no exception for `address(0)`. An implementation that burns tokens by transferring them to `address(0)` — thereby leaving `balanceOf(address(0)) > 0` — MUST report `address(0)` as a holder, since the alternative would violate the invariant and silently desynchronize `holderCount()` from the set enumerated by `holderByIndex`.

Implementations SHOULD instead burn by reducing `totalSupply()` without crediting any address, in which case `address(0)` never enters `H` and the question does not arise. This is the behaviour of every widely used [ERC-20](./eip-20.md) implementation.

### Additional Specifications

The contract MUST implement the [ERC-165](./eip-165.md) `supportsInterface` function and MUST return true for the `bytes4` value `0x21f021df`, representing the `interfaceId` of `IERC8300` — the exclusive-or of the selectors of `holderCount`, `holderByIndex`, `isHolder`, `holders`, and `holdersInRange`. The OPTIONAL events do not contribute to this identifier.

Implementations MUST NOT expose a reverse lookup from an address to its index. See [Rationale](#rationale).

This ERC does not mandate, and MUST NOT be read to imply, any restriction on who may hold or receive tokens. A conforming token MAY be freely transferable. Access control, allowlisting, and identity verification are out of scope and are addressed by [ERC-3643](./eip-3643.md) and [ERC-7943](./eip-7943.md), with which this ERC composes.

## Rationale

- **Minimalism.** The standard defines five view functions, one error, and two OPTIONAL events. It adds no privileged operations and no state that is not already implied by `balanceOf`. The five accessors are three presentations of one sequence — a point query (`isHolder`), a count (`holderCount`), a single-entry index (`holderByIndex`), a whole-set copy (`holders`), and a caller-bounded window (`holdersInRange`) — not five independent capabilities; each is a view over `H` and nothing else. Anything beyond enumeration — snapshots, identity, compliance — belongs in an extension or an orthogonal standard, and each is demonstrated under [Extensibility](#extensibility).

- **Fungible scope.** The standard is confined to [ERC-20](./eip-20.md). A multi-token variant keyed by token identifier was considered and deferred: it would double the surface area, introduce a second [ERC-165](./eip-165.md) identifier, and force every normative statement to be written twice, in exchange for serving a use case ([ERC-1155](./eip-1155.md) fungible identifiers) whose holder sets are already partitioned per identifier and are therefore better served by a separate proposal that can address per-identifier enumeration on its own terms. A future ERC MAY define that variant with the same vocabulary.

- **Single source of truth.** `H` is *defined* as `{ a : balanceOf(a) > 0 }` rather than as an independently mutated set that implementations are asked to keep in sync. This closes an entire class of bug by construction: there is no state of the world in which `isHolder(a)` and `balanceOf(a) > 0` may legitimately disagree, so any divergence is unambiguously a defect. It also forces the invariant to cover mint, burn, and enforcement transfers, which [ERC-884](./eip-884.md) left underspecified by stating the rule only on `transfer` and `transferFrom`.

- **Events are OPTIONAL, not required and not forbidden.** Membership of `H` is fully derivable from [ERC-20](./eip-20.md)'s `Transfer` event, since a balance crosses zero if and only if a transfer, mint, or burn moves it there. On that ground the events convey no information an indexer could not already compute, and requiring them would add a `LOG1` to the hot path of every crossing. That is the case for omitting them, and this ERC does not oblige any token to carry the cost.

  It is not, however, a case for forbidding them, because *derivable* and *cheaply observable* are different properties. Recovering `H` from the transfer log obliges a consumer to replay every transfer and track every balance in order to notice the crossings; the crossing itself is never announced. `HolderAdded` is a single indexed topic that a log-filtering consumer — a light client, a transfer agent's webhook, a subgraph that cares about the register and not the flow — can subscribe to directly, at no cost to anyone who does not want it. The same reasoning is why [ERC-721](./eip-721.md) emits `Transfer` on mint even though the balance change already implies it.

  Making the events OPTIONAL puts the `LOG1` where its cost is chosen rather than imposed: a permissioned register with a bounded holder set will pay it without noticing, a high-throughput freely transferable token will decline. Because [ERC-165](./eip-165.md) identifiers are computed from function selectors and not from events, the choice does not fork the interface or split the ecosystem into two detectable variants — an integrator that wants the events looks for them, and falls back to the `Transfer` log when they are absent, which it must be able to do in any case.

  This is a weaker position than [ERC-7943](./eip-7943.md)'s, whose `ForcedTransfer` and `Frozen` events are REQUIRED precisely because they signal state changes that are *not* derivable from the transfer log at all. Here the log is a convenience, so the standard makes it a choice.

  What the standard does insist on, for implementations that opt in, is that the events fire on the transitions of `H` and on nothing else. A log that also fired on non-crossing transfers, or that skipped the mint path, would break the running-total property in [Events](#events) and would leave an incremental indexer with a holder set that silently diverges from `balanceOf` — reintroducing the very class of desynchronisation bug that defining `H` in terms of `balanceOf` was meant to eliminate.

- **Array return, alongside the index accessor.** `holders() returns (address[] memory)` is included, and the two accessors are retained together because they serve different callers. [ERC-721](./eip-721.md)'s Rationale reached the opposite conclusion for its enumeration extension, considering and discarding *"return a Solidity array type from enumeration functions"*. This ERC departs from that precedent deliberately, on the grounds that the objection is decisive only for the on-chain caller, who is already forbidden from enumerating at all.

  The overwhelmingly common consumer of a holder register is an off-chain one: an issuer's transfer agent, an auditor, a block explorer. For that caller `holders()` is a single `eth_call` against a pinned block, which is atomic by construction, costs no gas, and cannot observe the torn read that paging across blocks invites. Obliging it to issue one `holderCount()` call followed by that many `holderByIndex` round trips — any of which may race a concurrent removal and silently skip or duplicate a holder, per [Security Considerations](#security-considerations) — trades a real correctness hazard for a gas saving that the caller never pays.

  The index accessor is not thereby redundant. It remains the only way to sample the set without materialising it, the only mechanism whose cost a caller can bound in advance, and the only one that survives a holder set large enough to exceed an RPC provider's gas cap. `holders()` is the ergonomic path; `holderByIndex` is the path that always works. Neither subsumes the other, and the specification is explicit that `holders()` MUST NOT be called on-chain.

- **A range accessor in the core, not only in an extension.** `holdersInRange(fromIndex, toIndex)` occupies the middle ground the other two enumerating accessors leave open. `holders()` reads the whole set in one call but cannot bound its own cost, so it fails outright once `H` exceeds a provider's gas cap — which is exactly when a large register most needs reading. `holderByIndex` bounds each call but costs one round trip per holder, so reading a 200,000-entry register is 200,000 requests. `holdersInRange` reads a caller-sized slice per call, so the same register is read in a few hundred requests, each of which the caller can size to fit its provider's limit. For the overwhelmingly common consumer — a transfer agent or auditor walking a register too large for `holders()` — this is the path that is both bounded and practical, and neither existing accessor provides it.

  It is placed in the core interface rather than deferred to an extension because that common consumer should be able to detect one interface via [ERC-165](./eip-165.md) and find the accessor it needs already present, rather than discovering that the single most useful register-reading function is an optional add-on a given token may or may not carry. The cost of that decision is honest and worth stating: it raises the mandatory surface from four functions to five, and it obliges even a small bounded register — one `holders()` serves completely — to implement a windowing function it will never need. The judgement here is that the register-walking caller is common enough, and the extra function cheap enough to implement over the same backing array, that carrying it in the core is the better trade. This reverses the position that pagination "belongs in an extension"; the reversal is deliberate, on the grounds that a *bounded contiguous read* is not an optional convenience over the core but the core's only safe answer to a large register.

  What `holdersInRange` is *not* is a fix for the cross-block torn read. A single window is atomic within its `eth_call`, but reassembling an `H` too large for `holders()` takes several windows, and the only way to keep those windows mutually coherent is to pin every one to the same block — the same discipline a `holderByIndex` loop needs, and no weaker. The accessor's advantage over that loop is round-trip count, not atomicity. The specification says so outright, so that no integrator mistakes a windowed read across live blocks for a consistent snapshot. Half-open bounds `[fromIndex, toIndex)` are used because they match the half-open ranges the rest of the specification already states (`0 ≤ i < holderCount()`), let adjacent windows tile the set without overlap or gap, and make `holders()` exactly `holdersInRange(0, holderCount())`; a `page`-numbered form was rejected because the swap-and-pop index cannot honour a stable page number.

- **No reverse lookup.** An `indexOfHolder(address)` function was rejected. The canonical implementation removes a holder by swapping the last entry into the vacated slot and popping, which mutates the index of an unrelated address. Exposing the index would invite callers to cache a value that changes silently under them. Since no correct caller can rely on it, the standard does not offer it.

- **Index instability is normative, not incidental.** The specification states outright that `holderByIndex` MAY return a different address for the same index after any state change. Making this explicit is what permits the O(1) swap-and-pop removal. The alternative — a stable, gap-free, insertion-ordered index — would require either an O(n) shift on removal or tombstones that break the `holderCount()` bound.

- **Compatibility.** The interface is additive. It changes no [ERC-20](./eip-20.md) semantics, mandates no `decimals` value, and blocks no transfer, so a conforming token remains tradeable on any venue that supports the base standard. This is the principal departure from [ERC-884](./eip-884.md), whose enumeration was inseparable from a KYC gate that rendered the token untradeable on permissionless venues, and which the standard's own authors conceded *"will make the standard unpalatable to some exchanges."*

- **[ERC-165](./eip-165.md).** Ensures integrators can detect enumeration support rather than probing with a speculative `staticcall` and interpreting a revert.

### Extensibility

The core interface is intentionally insufficient for several plausible use cases, each of which is better served by an extension than by an enlargement of the standard. (Windowed reading is *not* among them: the range accessor `holdersInRange` that would have lived here has been promoted into the core interface, for the reasons given under [Rationale](#rationale). A batch-by-index form — `holderByIndexBatch(uint256[] indices)` on [ERC-1155](./eip-1155.md)'s `balanceOfBatch` model — was considered as an alternative and rejected: it serves random access, which no register consumer needs, whereas a register is always read as a contiguous walk that a range expresses in two words of calldata.)

**1) Historical enumeration.** The core interface describes only the present. A token needing *"who held at block N"* — for a dividend or a retroactive airdrop — SHOULD checkpoint, and SHOULD adopt [ERC-6372](./eip-6372.md) to announce whether it measures time in block numbers or timestamps:

```solidity
function pastHolderCount(uint256 timepoint) external view returns (uint256 count);
function pastHolderByIndex(uint256 timepoint, uint256 index) external view returns (address holder);
```

Note that [ERC-5805](./eip-5805.md) already solves the narrower problem of weighing a *self-identifying* voter at a past timepoint, and needs no enumeration to do so. Reach for historical enumeration only when the consumer genuinely cannot enumerate off-chain.

**2) Dust filtering.** A token wishing to exclude economically irrelevant balances from `H` MUST NOT do so under this interface, since it would violate the normative definition. It SHOULD instead expose a parallel, clearly-named view:

```solidity
function significantHolderCount(uint256 minimumBalance) external view returns (uint256 count);
```

**3) Composition with compliance.** An [ERC-7943](./eip-7943.md) token can implement this interface directly; its `forcedTransfer` is simply another balance transition that MUST maintain the invariant. An [ERC-3643](./eip-3643.md) token gains a way to distinguish its *eligible* set (the identity registry) from its *actual* set (`H`), which is exactly the distinction its `canTransfer` holder-cap rules need in order to be checked cheaply.

### Notes on Naming

Every identifier in this standard is taken from a standard that already exists. No name is coined here.

The five names do not share a single grammatical shape — `holderCount` is a noun phrase, `holderByIndex` a noun with an access qualifier, `holders` a bare plural, `holdersInRange` a plural with a range qualifier, `isHolder` a predicate — and the inconsistency is deliberate. A uniform scheme (`getHolderCount`, `getHolderByIndex`, `getHolders`, `getIsHolder`, or equally `holderCount`, `holderIndex`, `holderAll`, `holderMember`) would be internally tidier but would match nothing an integrator has already written against. The governing rule here is instead: **each name is the one an existing Final or widely-deployed standard uses for that exact shape of query.** ERC-20, ERC-721, and ERC-1155 are themselves not internally uniform — `balanceOf`, `totalSupply`, `tokenByIndex`, `isApprovedForAll` — and this ERC inherits that irregularity rather than imposing a consistency the corpus does not have. The concrete derivations follow.

- **`holderCount`** and **`isHolder`** are adopted verbatim from [ERC-884](./eip-884.md), including their return types. That standard is `Stagnant` and its verification machinery is not carried over, but its enumeration vocabulary is the only prior art in the ERC corpus and is worth preserving. `totalHolders`, which would mirror [ERC-20](./eip-20.md)'s `totalSupply`, was rejected on two grounds: it has no prior art for an address count, and the parallel with `totalSupply` is precisely the false inference the specification warns against, since `holderCount()` bears no relationship to the supply. The `is` prefix on `isHolder` is retained because the function returns a `bool` predicate, following `isApprovedForAll` in [ERC-721](./eip-721.md) and `isValidSignature` in [ERC-1271](./eip-1271.md); a noun form such as `holderStatus` would obscure the return type at the call site.
- **`holderByIndex`** renames ERC-884's `holderAt`. The `<subject>ByIndex` form is established by [ERC-721](./eip-721.md)'s `tokenByIndex` and `tokenOfOwnerByIndex`, which is `Final` and has orders of magnitude more integration than ERC-884. Where the two conflict, this ERC follows the standard that integrators have actually implemented against.
- **`holders`** is the plural of the noun the other three accessors already share, and returns exactly what its name says. `getHolders` was rejected: the `get` prefix appears nowhere in the accessor vocabulary of [ERC-20](./eip-20.md), [ERC-721](./eip-721.md), or [ERC-1155](./eip-1155.md). `holderSet` and `allHolders` were rejected as restating in the identifier what the return type and the specification already establish.
- **`holder`** is preferred over `owner`, `shareholder`, or `account`. `owner` is claimed by [ERC-721](./eip-721.md)'s `ownerOf` with a stronger meaning — exclusive title to a discrete object — which a fractional fungible balance does not confer. `shareholder` presumes an equity instrument. `account` is used throughout this document for an arbitrary address, and would blur the distinction between an address and a *holding* address, which is precisely what `isHolder` exists to test.
- **`HolderAdded`** and **`HolderRemoved`** name the transition of the *set*, not of the balance that caused it, and take the past-participle form that [ERC-20](./eip-20.md)'s `Approval`, [ERC-721](./eip-721.md)'s `ApprovalForAll`, and [ERC-7943](./eip-7943.md)'s `Frozen` all use for a state change that has already happened. `Added` / `Removed` are also the verbs the specification itself uses for `H` (*"`a` MUST be inserted into `H`"*, *"`a` MUST be removed from `H`"*) and the operations of the `EnumerableSet` primitive the canonical implementation is built on, so the event names, the normative prose, and the implementation all speak of the same act.

  Three alternatives were rejected. `HolderRegistered` / `HolderDeregistered` implies a registry — an authority admitting and expelling members — which is exactly what this ERC is not, and would invite confusion with [ERC-3643](./eip-3643.md)'s identity registry. `HolderCountChanged(uint256 newCount)` would report the aggregate rather than the member, forcing a consumer that wants to know *who* to go back to the transfer log, which defeats the purpose of emitting at all. `BalanceCrossedZero` names the mechanism instead of the meaning; the mechanism is already visible in `Transfer`, and it is the membership change that a consumer subscribes for.

- **`ERC8300OutOfBoundsIndex`** follows the `<ERC><Domain><Issue>` convention of [ERC-6093](./eip-6093.md) and matches the `ERC721OutOfBoundsIndex` error already shipped by widely deployed enumeration implementations. It supersedes ERC-721's prose instruction to *"throw"*, which predates custom errors. The `count` parameter is included so a caller that raced against a concurrent removal learns the new bound from the revert data rather than by re-querying.
- **`ERC8300InvalidRange`** is a second error, distinct from the one above, and the two are split by *kind of failure* rather than by accessor. `ERC8300OutOfBoundsIndex` means "a requested index is past the end of the set," and its `count` parameter is always the current holder count; both `holderByIndex` and `holdersInRange`'s `toIndex > holderCount()` check raise it, so the past-the-end discipline is uniform. `ERC8300InvalidRange` means "the range is internally inconsistent" (`fromIndex > toIndex`), where neither argument is a holder count and reusing the bounds error would put a non-count value in its `count` slot, corrupting the revert data an [ERC-6093](./eip-6093.md)-style decoder relies on. Splitting a range accessor's failures per accessor — an `IndexOutOfBounds` here, an `OffsetOutOfBounds` there — was rejected: the caller already knows which function it called, so that axis conveys nothing, whereas out-of-bounds versus malformed-range is a distinction the caller genuinely cannot infer from the call site.
- **`holdersInRange`** reuses the `holders` plural the core already establishes and qualifies it with the index range it returns, its parameters named `fromIndex` / `toIndex` to state the half-open `[fromIndex, toIndex)` interval at the call site. The `from`/`to` shape was chosen over the equivalent `holdersFrom(offset, limit)` for two reasons. First, both parameters are *indices* into the same sequence, bounded by `holderCount()`, so the accessor stays in the single coordinate space the rest of the specification speaks in, rather than mixing an index (`offset`) with a count (`limit`). Second, an absolute `toIndex` reuses `holderByIndex`'s existing out-of-bounds rule verbatim — the function reverts `ERC8300OutOfBoundsIndex` when `toIndex` passes the end, so there is one out-of-range discipline and one error across both index accessors — and it makes `holders()` exactly `holdersInRange(0, holderCount())`. The acknowledged cost is that a caller paging in fixed strides must clamp `toIndex` to `holderCount()` on the final window, where `offset`/`limit` would have let `limit` self-truncate; the choice weighs uniform semantics over that one convenience, on the grounds that a loud revert past the end suits a register better than a silent short read. `holdersByPage(page, size)` was rejected because "page" implies a stable page number that the swap-and-pop index cannot honour, and `holderSlice` because `slice` has no precedent in the ERC accessor corpus. A batch-by-index form on the [ERC-1155](./eip-1155.md) `balanceOfBatch` model was rejected on the substantive grounds given under [Extensibility](#extensibility), not merely on naming.

## Backwards Compatibility

This ERC defines a new optional interface and alters no existing one. It imposes no constraint on `decimals`, `totalSupply`, or transfer behaviour. Wallets, explorers, and protocols that do not recognise it interact with the base [ERC-20](./eip-20.md) token exactly as before.

It is strictly weaker than [ERC-884](./eip-884.md) in requirements and strictly compatible with it in vocabulary: an ERC-884 token satisfies this ERC's semantics for `holderCount` and `isHolder`, and satisfies `holderByIndex` under the `holderAt` → `holderByIndex` rename. ERC-884 tokens are not automatically conforming, because they do not implement [ERC-165](./eip-165.md) detection for this interface.

## Reference Implementation

The reference implementation belongs in `../assets/eip-8300/`. The essential mechanism is the insertion and swap-and-pop removal hooked to balance transitions across zero:

```solidity
// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.20;

abstract contract ERC8300 is ERC20, ERC165, IERC8300 {
    address[] private _holders;
    mapping(address => uint256) private _holderIndex; // 1-based; 0 means "not a holder"

    function holderCount() public view returns (uint256) {
        return _holders.length;
    }

    function holderByIndex(uint256 index) public view returns (address) {
        if (index >= _holders.length) revert ERC8300OutOfBoundsIndex(index, _holders.length);
        return _holders[index];
    }

    function isHolder(address account) public view returns (bool) {
        return _holderIndex[account] != 0;
    }

    /// @dev Copies the entire holder array from storage into memory. Intended for `eth_call`.
    /// An on-chain caller invoking this inherits an unbounded, attacker-controlled cost.
    function holders() public view returns (address[] memory) {
        return _holders;
    }

    /// @dev Half-open window `[fromIndex, toIndex)` over the same array. The revert carries the
    /// current length so a caller that raced a removal reads the new bound from the error.
    /// `fromIndex == toIndex` returns an empty array (the paging-loop terminator) without reverting.
    function holdersInRange(uint256 fromIndex, uint256 toIndex) public view returns (address[] memory window) {
        if (fromIndex > toIndex) revert ERC8300InvalidRange(fromIndex, toIndex);
        if (toIndex > _holders.length) revert ERC8300OutOfBoundsIndex(toIndex, _holders.length);
        window = new address[](toIndex - fromIndex);
        for (uint256 i = 0; i < window.length; ++i) window[i] = _holders[fromIndex + i];
    }

    /// @dev `_update` is OpenZeppelin v5's single choke point for transfer, mint, and burn.
    /// Hooking it here is what makes the invariant hold across every balance transition.
    function _update(address from, address to, uint256 value) internal virtual override {
        super._update(from, to, value);
        if (from != address(0) && balanceOf(from) == 0) _removeHolder(from);
        if (to != address(0) && balanceOf(to) != 0) _addHolder(to);
    }

    /// @dev The `emit` is inside the membership guard, not beside it: a mint to an existing
    /// holder reaches this function but returns early, so no event fires. Omit both `emit`
    /// statements to implement the interface without the OPTIONAL log.
    function _addHolder(address account) private {
        if (_holderIndex[account] != 0) return;
        _holders.push(account);
        _holderIndex[account] = _holders.length;
        emit HolderAdded(account);
    }

    function _removeHolder(address account) private {
        uint256 oneBased = _holderIndex[account];
        if (oneBased == 0) return;
        uint256 last = _holders.length - 1;
        if (oneBased - 1 != last) {
            address moved = _holders[last];
            _holders[oneBased - 1] = moved;
            _holderIndex[moved] = oneBased; // the moved holder's index changes silently
        }
        _holders.pop();
        delete _holderIndex[account];
        emit HolderRemoved(account);
    }

    function supportsInterface(bytes4 id) public view virtual override returns (bool) {
        return id == type(IERC8300).interfaceId || super.supportsInterface(id);
    }
}
```

Three details carry the correctness of the whole extension. The index mapping is **1-based**, so the default zero value distinguishes "not a holder" from "holder at index 0" without a second lookup. The hook is placed at the base implementation's single balance-mutating choke point, so mint (`from == address(0)`) and burn (`to == address(0)`) are covered by the same code path as `transfer` — the omission that leaves ERC-884's specification incomplete. And each `emit` sits *after* the early-return guard that tests membership, which is what makes the log report transitions of `H` rather than balance changes: `_addHolder` is reached on every credit, but returns before the `emit` when the recipient already held. Emitting from `_update` instead, beside the guard rather than inside it, is the natural mistake and would announce a new holder on every top-up.

Note that neither `holders()` nor `holdersInRange` requires additional state. The canonical implementation already materialises `_holders` as a storage array in order to serve `holderByIndex` in O(1), so `holders()` returning it whole is a copy, not a construction, and `holdersInRange` is a bounded copy of a contiguous slice of the same array. The sequence-equality properties of the previous section are satisfied trivially, because all three accessors read the same array in the same order. An implementation that backs `holderByIndex` with some other structure — a linked list, say — MUST take care that `holders()` and `holdersInRange` walk that structure in the identical order, which for a range means the window `[fromIndex, toIndex)` must be the same holders `holderByIndex` returns for those indices.

This example is provided for educational purposes only and is not audited.

## Security Considerations

- **The holder set is unbounded and adversarially inflatable.** On a freely transferable token, anyone may append an arbitrary number of entries to `H` by sending one wei to freshly generated addresses, at a cost of one warm `SSTORE` plus calldata per entry. `holderCount()` therefore admits no upper bound that an implementation can enforce without breaking the invariant.

  The direct consequence: **no contract may iterate `holderByIndex`, call `holders()`, or call `holdersInRange` with an unbounded range, from within a transaction.** A protocol that loops from `0` to `holderCount()` — to distribute a dividend, to snapshot, to tally — can be rendered permanently un-callable by an attacker for the price of the dust. `holdersInRange` bounds its cost by the caller's own arguments, so a *fixed* small range is safe on-chain; the hazard returns the moment the range is derived from `holderCount()`, since that upper bound is itself attacker-inflated. This is a griefing vector of the same family as the unbounded-loop hazard [ERC-721](./eip-721.md) warns of in its enumeration Rationale, and it is more easily triggered here, because minting an NFT is typically permissioned whereas receiving a fungible transfer is not. The functions in this ERC are intended for `eth_call`, where iteration is free and abandonment is costless.

- **`holders()` concentrates that hazard into a single call.** The index accessor at least obliges an unsafe integrator to write a visible loop, which a reviewer may recognise. `holders()` presents the same unbounded cost as one innocuous-looking expression, and an integrator who writes `token.holders().length` inside a state-changing function has introduced an attacker-triggered denial of service with no loop in sight. The array is copied to memory in full before any code the caller wrote begins to execute, so neither an early `break` nor a length check can rescue it.

  Implementers are therefore cautioned that adding `holders()` to a token does not merely offer a convenience; it lowers the cost of a mistake that the index accessor made conspicuous. Integrators MUST treat `holders()` as an off-chain-only interface, and SHOULD prefer `holderByIndex` in any code path that a contract can reach. A token whose holder set is bounded by an allowlist — via [ERC-3643](./eip-3643.md) or [ERC-7943](./eip-7943.md) — is exempt from this reasoning only to the extent that the bound is enforced on `canReceive` and not merely on `canTransfer`.

  [ERC-884](./eip-884.md) escapes this only because its verification gate bounds `H` to the set of KYC'd addresses. Tokens that adopt this ERC together with an allowlist — for instance via [ERC-3643](./eip-3643.md) or [ERC-7943](./eip-7943.md)'s `canReceive` — inherit that bound. Tokens that adopt it standalone do not, and their integrators MUST assume `holderCount()` is attacker-controlled.

- **Indices are unstable across transactions.** `holderByIndex(i)` may name a different address before and after any balance change, because removal swaps the final entry into the vacated slot. A caller paging through the set across multiple blocks — whether by successive `holderByIndex` calls or by successive `holdersInRange` windows — can therefore observe a holder twice, or miss one entirely, without any call ever reverting. `holdersInRange` does not repair this: a window is internally consistent, but two windows read in different blocks are no more coherent with each other than two `holderByIndex` calls are. Consumers requiring a coherent view MUST read the whole set within a single block — via `eth_call` at a pinned block number, a batch RPC, or a multicall — or MUST use a checkpointed extension. Persisting an index across transactions as a reference to a holder is always a defect.

- **Gas cost lands on the hot path.** Maintaining `H` adds, in the worst case, an array push plus an index write on a zero-to-non-zero transition, and a swap plus two index writes plus a pop on the reverse — plus a `LOG1` on each, for an implementation that emits the OPTIONAL events. Transfer gas therefore becomes *conditional on the recipient's and sender's prior balances*, which breaks the flat-cost assumption that some integrators, relayers, and gas estimators make about [ERC-20](./eip-20.md) transfers. The variance is at its widest on the very transfers an attacker controls, since dusting a fresh address is precisely the path that pays the insertion. Implementers SHOULD document the worst-case transfer cost.

- **Reentrancy and hook ordering.** Plain [ERC-20](./eip-20.md) has no transfer hooks, but [ERC-777](./eip-777.md) and [ERC-1363](./eip-1363.md) implementations may call into the sender or recipient. `H` MUST be brought into agreement with the new balances *before* any such external call, so that a reentrant `holderCount()` or `isHolder()` never observes a set that contradicts `balanceOf`. Implementations SHOULD follow checks-effects-interactions and MAY apply a reentrancy guard. The ordering requirement mirrors [ERC-7943](./eip-7943.md)'s reasoning for emitting `Frozen` before the underlying transfer event.

- **Enumeration is a privacy surface, not a privacy leak.** Every address in `H` is already recoverable from the public `Transfer` log. This ERC changes the cost of obtaining the set, not its confidentiality: it makes the holder list available to a light client, an on-chain caller, and any RPC endpoint, rather than only to an archive node or an indexer. The OPTIONAL events lower that cost further, since they reduce the holder register to a single `eth_getLogs` topic filter that anyone may run against a public endpoint. Issuers of tokens with a sensitive holder base should weigh that reduction in friction, and are among those for whom declining to emit is the right choice. Neither decision is a substitute for a privacy-preserving design.

- **`holderCount()` is not a Sybil-resistant measure.** It counts addresses, not people. It MUST NOT be used as a governance quorum denominator, an airdrop eligibility signal, a proxy for decentralisation, or any input where an attacker profits from inflating it. Where a shareholder cap must be enforced — the [ERC-884](./eip-884.md) use case — the count is only meaningful because the verification gate makes each entry a distinct verified identity.

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).
