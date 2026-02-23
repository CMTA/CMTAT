# CMTAT Codebase Summary

**CMTAT** (CMTA Token) is a **security token framework** for tokenizing real-world financial assets on EVM-compatible blockchains. It's developed by the Capital Markets and Technology Association (CMTA).

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
test/                        # 3,078 tests (~99% coverage)
doc/                         # Specs & audit reports
```

**Contracts tree**

See `./claude/tree/contracts_tree.txt`

**Test tree**

See `./claude/tree/test_tree.txt`

**openzeppelin/contracts-upgradeable**

See `./claude/tree/contracts-upgradeables_tree.txt`

## Key Modules

See `./doc/summary.md`

## Deployment Variants

See `./doc/summary.md`

---

## Architecture Highlights

See `./doc/summary.md`

---

## Contract Inheritance Hierarchy

See `./doc/summary.md`

---

## Key Roles (Access Control)

See `./doc/summary.md`

---

## Useful Commands

```bash
npm run test                  # Run all tests
npm run coverage              # Generate coverage report
npm run hardhat:compile       # Compile contracts
```

---

## Key Files to Understand

- `contracts/modules/0_CMTATBaseCore.sol` - Core base contract
- `contracts/deployment/CMTAT_*.sol` - Pre-composed deployment variants
- `contracts/interfaces/` - All supported interfaces and standards
- `hardhat.config.js` - Build configuration (EVM & Solidity version)
- `package.json` - Dependencies and scripts
