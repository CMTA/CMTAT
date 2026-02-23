# CMTAT Codebase Summary

**CMTAT** (CMTA Token) is a **security token framework** for tokenizing real-world financial assets on EVM-compatible blockchains. It's developed by the Capital Markets and Technology Association (CMTA).

**Version:** 3.1.0 | **License:** MPL-2.0 | **Solidity:** 0.8.33

---

## Directory Structure

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

---

## Key Modules

| Category | Modules | Purpose |
|----------|---------|---------|
| **Core** | ERC20Base, Mint, Burn, Pause, Enforcement, Validation | Basic token operations |
| **Extensions** | Snapshot, Document, ExtraInformation | Dividends, legal docs, metadata |
| **Options** | Debt, ERC2771, ERC1363, CrossChain, Allowlist, ERC7551 | Bonds, gasless tx, multi-chain, KYC |
| **Security** | AccessControl | RBAC with roles (MINTER, BURNER, PAUSER, ENFORCER) |

---

## Deployment Variants

- **Standalone** - Immutable, no proxy
- **Upgradeable** - Transparent/Beacon/UUPS proxy patterns
- **Light** - Minimal for stablecoins
- **Allowlist** - Whitelist-based transfers (KYC)
- **Debt** - Bond-specific fields (maturity, coupon)
- **DebtEngine** - Debt with external engine
- **ERC-7551** - German eWpG compliance
- **ERC-1363** - transferAndCall support

---

## Architecture Highlights

1. **Modular composition** - Mix-and-match features via inheritance
2. **Engine pattern** - External contracts for complex logic (RuleEngine, SnapshotEngine, DocumentEngine, DebtEngine)
3. **ERC-7201 storage** - Namespaced storage for safe upgrades
4. **Role-based access control** - Granular permissions (not single owner)
5. **10+ standard compliance** - ERC-20, ERC-3643, ERC-7551, ERC-2771, ERC-7802, etc.

---

## Contract Inheritance Hierarchy

```
CMTATBaseCore (0) - Basic ERC20 + Mint + Burn + Validation + Access Control
    ↓
CMTATBaseAccessControl (1) - RBAC roles management
    ↓
CMTATBaseRuleEngine/Allowlist (2) - Transfer validation rules
    ↓
CMTATBaseERC1404 (3) - ERC-1404 compliance (restrictedTransfer)
    ↓
CMTATBaseERC20CrossChain (4) - CCIP & ERC-7802 support
    ↓
CMTATBaseERC2771 (5) - Gasless meta-transactions
    ↓
CMTATBaseERC1363/ERC7551 (6) - Additional standards
```

---

## Key Roles (Access Control)

- `DEFAULT_ADMIN_ROLE` - Admin access (can grant/revoke roles)
- `MINTER_ROLE` - Can mint tokens
- `BURNER_ROLE` - Can burn tokens
- `PAUSER_ROLE` - Can pause/unpause contract
- `ENFORCER_ROLE` - Can freeze/unfreeze addresses

---

## Real-World Usage

Used by UBS (digital bonds), Daura (equity), Taurus, and others for tokenizing securities, stablecoins, and structured products.

---

## Testing & Security

- **Framework:** Hardhat + Chai
- **Coverage:** ~99.43%
- **Audits:** ABDK, Halborn
- **Static analysis:** Aderyn, Slither

---

## Useful Commands

```bash
npm run test                  # Run all tests
npm run test:integration      # Full integration tests
npm run coverage              # Generate coverage report
npm run hardhat:compile       # Compile contracts
```

---

## Key Files to Understand

- `contracts/modules/0_CMTATBaseCore.sol` - Core base contract
- `contracts/deployment/CMTAT_*.sol` - Pre-composed deployment variants
- `contracts/interfaces/` - All supported interfaces and standards
- `hardhat.config.js` - Build configuration
- `package.json` - Dependencies and scripts
