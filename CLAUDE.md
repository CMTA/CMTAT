# CMTAT Codebase Summary

**CMTAT** (CMTA Token) is a **security token framework** for tokenizing real-world financial assets on EVM-compatible blockchains. It's developed by the Capital Markets and Technology Association (CMTA).

AGENTS.md and CLAUDE.md files must always be identical
Module numbering must strictly match dependency order (a lower-level module must not depend on a higher-level module).

**Solidity** | **Hardhat**

---

## Directory Structure

If you create/move/remove a file/directory from this project, update the different file trees path corresponding.

Only run listing command such as `ls/tree` if you don't manage to use the tree structure here to find the directory and corresponding files.

**Directory structure**

```
contracts/
├── modules/                  # Core smart contract logic
│   ├── internal/            # Internal implementations
│   └── wrapper/             # Public-facing modules
│       ├── core/            # ERC20, Pause, Enforcement, Validation
│       ├── extensions/      # Documents, Snapshots
│       ├── options/         # Debt, ERC2771, Cross-chain
│       └── security/        # Access control
├── deployment/              # Pre-composed contract variants
├── interfaces/              # ERC standards & custom interfaces
└── mocks/                   # Test helpers
test/                        # 5,630 tests (~99% coverage)
doc/                         # Specs & audit reports
```

**Contracts tree**

See `./claude/tree/contracts_tree.txt`

**Test tree**

See `./claude/tree/test_tree.txt`

**openzeppelin/contracts-upgradeable**

See `./claude/tree/contracts-upgradeables_tree.txt`

## Key Modules

See `./doc/SUMMARY.md`

## Deployment Variants

See `./doc/SUMMARY.md`

---

## Architecture Highlights

See `./doc/SUMMARY.md`

---

## Contract Inheritance Hierarchy

See `./doc/SUMMARY.md`

---

## Key Roles (Access Control)

See `./doc/SUMMARY.md`

---

## Useful Commands

```bash
npm run test                  # Run all tests
npm run coverage              # Generate coverage report
npm run hardhat:compile       # Compile contracts
```

## Test Catalogue

The test suite is catalogued per feature module and per deployment version in **[doc/test/Test.md](doc/test/Test.md)**
— a hand-maintained map whose purpose is to make **missing tests easy to find**.

**Whenever you add, change or remove a test, update `doc/test/Test.md` in the same change:**
- test added → adjust the module's `it` count / scenario, and add a matrix row or column if it covers a new feature or variant;
- test removed → remove it, and note any resulting coverage gap;
- new deployment variant or shared test module → add the corresponding matrix column / row and module-reference entry.

An out-of-date catalogue is worse than none — keep it in sync.

## Test Troubleshooting

If tests fail with gas reporter / Mocha reporter errors (for example `ERR_MOCHA_INVALID_REPORTER` with `eth-gas-reporter`), run tests with gas reporting disabled:

```bash
DeactivateReportGas=true npx hardhat test
```

---

## Key Files to Understand

- `contracts/modules/0_CMTATBaseCore.sol` - Core base contract
- `contracts/deployment/CMTAT_*.sol` - Pre-composed deployment variants
- `contracts/interfaces/` - All supported interfaces and standards
- `hardhat.config.js` - Build configuration (EVM & Solidity version)
- `package.json` - Dependencies and scripts

## Documentation Lookup

Before stating that something is **not documented**, search **all** of the documentation surfaces below. They
overlap and none of them is authoritative on its own — a rationale is often recorded in one place and the
per-function facts in another.

| Surface | What lives there |
| --- | --- |
| `doc/README.md` | The largest document. Standards mapping (ERC-3643, ERC-7943, ERC-7551, ERC-7802), architecture, module list, access control, engines, and the **Enforcement / Transfer restriction** chapter — including behavioural rationales such as why pause does not block issuer mint/burn. |
| `doc/USAGE.md` | Build, test, deploy and tooling instructions. |
| `doc/modules/**` | Per-module reference pages (`core/`, `extensions/`, `options/`, `controllers/`), one per module, with per-function requirements, events and errors. |
| `doc/technical/**` | Cross-cutting topics: `access-control.md`, `cross-chain-bridge-integration.md`, `deployment.md`, `upgradeable.md`, `stablecoin.md`, ERC-specific notes. |
| `doc/SUMMARY.md` | Short index of modules, deployment variants and roles. |
| `doc/security/**` | Audit reports and maintainer feedback. |
| `contracts/**` NatSpec + inline comments | Design rationales are frequently recorded only in code comments (e.g. the `onlyTokenBridge` `msg.sender` justification). |

Practical rule: grep the whole `doc/` tree **and** `contracts/`, not a subset.

```bash
grep -rn -i "<topic>" doc/ contracts/ --include=*.md --include=*.sol | grep -v doc/hardhat-compilation
```

Exclude `doc/hardhat-compilation/` (flattened build artifacts, including vendored OpenZeppelin comments) — matches
there are **not** CMTAT statements and must not be quoted as project documentation.

## Note

After each implemented feature or fix, provide a one-line GitHub commit message for all changes since the last commit.
