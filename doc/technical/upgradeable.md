# Upgradeable Proxy

CMTAT supports deployment via proxy contracts, which allows upgrading the contract logic after deployment using the standard proxy upgrade pattern.

## Proxy Variants

| Proxy type | Implementation contract |
|---|---|
| Transparent Proxy or Beacon Proxy | `CMTATStandardUpgradeable` (named `CMTATUpgradeable` up to v3.2.0) and the other `CMTATUpgradeable*` variants |
| UUPS Proxy | `CMTATUpgradeableUUPS` |

See [OpenZeppelin Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/) for deployment tooling.

## Storage Layout (ERC-7201)

CMTAT implements [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201) for namespaced storage locations. This ensures storage slots are deterministic and do not collide across upgrades or when modules are composed.

Each module stores its state under a fixed `bytes32` slot derived from a namespace string. See [`deployment.md`](./deployment.md) for the full slot table.

## Upgrading an Existing Proxy to v3.3.0

Upgrading a proxy deployed with v3.2.0 or earlier is **not** a drop-in implementation swap. Several changes do not
revert anything; they silently change what the token returns or which external calls it makes:

| Change | What you see after a plain upgrade | What to do |
| --- | --- | --- |
| `name` / `symbol` moved to `CMTAT.storage.TokenAttributeModule` (all variants, including Light) | `name()` / `symbol()` return empty strings; the EIP-712 domain used by `permit` changes | Read them before the upgrade and restore them in the same transaction (`upgradeToAndCall` / `upgradeAndCall` with a `reinitializer` or `setName` / `setSymbol`) |
| Documents stored in the token instead of an external DocumentEngine (all variants except Light) | Documents of the old engine are no longer returned; `setDocumentEngine` is gone | Export them before the upgrade and register them again with `setDocument` |
| SnapshotEngine removed from Standard, UUPS, ERC-1363, ERC-7551 and Allowlist | The engine stops receiving transfers; later snapshots are wrong | Upgrade a Standard proxy to the Snapshot variant instead (the engine address is kept); the other variants have no v3.3.0 equivalent with snapshots |
| RuleEngine receives mint, burn and the minter transfer on the 4-argument `transferred` | A rule enforced only in the engine's 3-argument overload no longer applies to mint and burn | Check the engine before upgrading the token (see [ruleengine-integration.md](./ruleengine-integration.md#breaking-changes-by-version)) |

Full details, the storage tables and the upgrade checklists (from v3.2.0 and from the audited v3.0.0) are in
[breaking-changes.md](./breaking-changes.md). Validate the layout with the OpenZeppelin upgrades plugin
(`validateUpgrade`), test the upgrade on a fork, and assert `name()`, `symbol()`, `getAllDocuments()` and
`snapshotEngine()` afterwards.

## Initialize Functions

Upgradeable contracts use `initialize` instead of a constructor. Each module exposes two initializer variants:

- `__{ContractName}_init` — calls the module's own initializer **and** all parent initializers (linearized).
- `__{ContractName}_init_unchained` — calls only the module's own initializer, **without** parent calls.

When building a custom contract, call `_init_unchained` in your initializer to avoid double-initialization. Do not call two `_init` variants from the same inheritance chain.

From the [OpenZeppelin documentation](https://docs.openzeppelin.com/contracts/5.x/upgradeable#multiple-inheritance):

> Initializer functions are not linearized by the compiler like constructors. Each `__{ContractName}_init` function embeds the linearized calls to all parent initializers. Calling two of these `init` functions can potentially initialize the same contract twice.

## UUPS Proxy

The UUPS variant (`CMTATUpgradeableUUPS`) embeds the upgrade logic inside the implementation contract itself. The proxy is simpler and cheaper, but the upgrade authority is tied to the token's `DEFAULT_ADMIN_ROLE`.

**Security note**: There is no segregation between the contract admin role and the proxy upgrade authority. A compromised `DEFAULT_ADMIN_ROLE` could allow an attacker to swap the implementation. Strongly consider using a multisig or a timelock for the admin account.

### UUPS Proxy Key Management

The admin key must be kept secure. An improvement would be to add a dedicated owner role with upgrade-only rights, separate from the token admin.

## Forwarder (ERC-2771)

For upgradeable deployments with `ERC2771Module`, the forwarder address is stored in the implementation contract's bytecode rather than proxy storage. This means it **can** be changed by deploying a new implementation — unlike standalone deployments where the forwarder is immutable.

## Further Reading

- [OpenZeppelin - Writing Upgradeable Contracts](https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable)
- [RareSkills - ERC-7201 Namespaced Storage](https://www.rareskills.io/post/erc-7201)
