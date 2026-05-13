# CMTA Token (CMTAT)

> Latest audited release: [v3.0.0](https://github.com/CMTA/CMTAT/releases/tag/v3.0.0)

CMTAT is an open-source **security token framework** for tokenizing real-world financial assets on EVM-compatible blockchains. It is developed and maintained by the [Capital Markets and Technology Association](https://www.cmta.ch/) (CMTA).

## What is CMTAT?

CMTAT extends the standard [ERC-20](https://eips.ethereum.org/EIPS/eip-20) token with compliance features required for regulated financial instruments:

| Feature | Purpose |
|---|---|
| **Pause** | Freeze all transfers globally (e.g., during corporate actions) |
| **Account Freeze** | Block specific addresses from transferring |
| **Transfer Validation** | Plug-in rule engine to restrict transfers by origin, receiver, or amount |
| **Forced Transfer** | Admins can move tokens from frozen accounts |
| **Snapshots** | Record balances at a specific point in time (e.g., for dividends) |
| **Documents** | Attach legal documents to the token on-chain |

## Who uses CMTAT?

CMTAT is used in production by major financial institutions including **UBS**, **Taurus SA**, **Daura**, **Fireblocks**, and **Syz Group** to tokenize equities, bonds, structured products, money market funds, and stablecoins.

## Supported Financial Instruments

| Product | Deployment Version |
|---|---|
| Equities | CMTAT Standard |
| Equities (Germany / eWpG) | CMTAT ERC-7551 |
| Debt / Bonds | CMTAT Debt |
| Stablecoins | CMTAT Light |
| Allowlist / Whitelist | CMTAT Allowlist |
| Permit + Multicall | CMTAT Permit |

Each product comes in a **standalone** (immutable) or **upgradeable** (proxy) variant.

## Key Standards

CMTAT implements a wide set of Ethereum standards:

- **ERC-20** — fungible token
- **ERC-3643** — security token (without on-chain identity)
- **ERC-7551** — crypto security token interface (eWpG profile)
- **ERC-7943 (uRWA)** — universal RWA interface
- **ERC-1404** — restricted token
- **ERC-2612 Permit** — gasless approvals
- **ERC-2771** — meta-transactions (gasless)
- **ERC-7802** — cross-chain transfers
- **ERC-7201** — storage namespaces for upgradeability

## Security

CMTAT has been audited by [ABDK](https://abdk.consulting) (v1.0, v2.3.0) and [Halborn](https://www.halborn.com) (v3.0.0), with ~99% test coverage across 3,078 automated tests.

See [SECURITY.md](./SECURITY.md) for the responsible disclosure policy.

## License

[MPL-2.0](./LICENSE.md) — weak copyleft, allows commercial use.

## Getting Started

```bash
# Install dependencies
npm install

# Compile contracts
npm run hardhat:compile

# Run all tests
npm run test

# Generate coverage report
npm run coverage
```

## Documentation

Full specification, architecture details, module descriptions, and ERC compatibility tables are in **[doc/README.md](./doc/README.md)**.

Additional resources:

- [Usage Guide](./doc/USAGE.md)
- [Specification PDF (v3.0.0)](./doc/specification/CMTATSpecificationV3.0.0.pdf)
- [Specification PDF (v3.1.0)](./doc/specification/CMTATSpecificationV3.1.0.pdf)
- [Security Reports](./doc/security/)
- [CMTA Website](https://cmta.ch/)
- [GitHub Releases](https://github.com/CMTA/CMTAT/releases)
