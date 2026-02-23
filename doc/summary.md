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