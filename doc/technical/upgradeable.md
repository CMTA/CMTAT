# Upgradeable Proxy

CMTAT supports deployment via proxy contracts, which allows upgrading the contract logic after deployment using the standard proxy upgrade pattern.

## Proxy Variants

| Proxy type | Implementation contract |
|---|---|
| Transparent Proxy or Beacon Proxy | `CMTATUpgradeable` |
| UUPS Proxy | `CMTATUpgradeableUUPS` |

See [OpenZeppelin Upgrades Plugins](https://docs.openzeppelin.com/upgrades-plugins/1.x/) for deployment tooling.

## Storage Layout (ERC-7201)

CMTAT implements [ERC-7201](https://eips.ethereum.org/EIPS/eip-7201) for namespaced storage locations. This ensures storage slots are deterministic and do not collide across upgrades or when modules are composed.

Each module stores its state under a fixed `bytes32` slot derived from a namespace string. See [`deployment.md`](./deployment.md) for the full slot table.

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
