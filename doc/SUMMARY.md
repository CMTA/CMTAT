## Deployment Variants

- **Standard** (`CMTATStandardStandalone` / `CMTATStandardUpgradeable`) - Core features, no snapshot engine
- **Snapshot** (`CMTATStandaloneSnapshot` / `CMTATUpgradeableSnapshot`) - Same as standard + SnapshotEngine support
- **Light** - Minimal for stablecoins
- **Allowlist** - Whitelist-based transfers (KYC)
- **Debt** - Bond-specific fields (maturity, coupon)
- **DebtEngine** - Debt with external engine + SnapshotEngine support
- **ERC-7551** - German eWpG compliance
- **ERC-1363** - transferAndCall support
- **Permit** - ERC-2612 gasless approvals + ERC-6357 multicall
- **UUPS** - Same as standard with UUPS proxy support

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
Level 0 (independent mixins):
  CMTATBaseCommon  - Core ERC20 + Mint + Burn + Validation + Access Control
  CMTATBaseCore    - Core modules only (light variant)
  CMTATBaseGeneric - Non-ERC20 modules only
  CMTATBaseSnapshot - Pure mixin: ERC20Upgradeable + SnapshotEngineModule (_update hook)

Standard chain (no snapshot):
  CMTATBaseCommon (0)
      ↓
  CMTATBaseAccessControl (1) - RBAC roles management
      ↓
  CMTATBaseRuleEngine / CMTATBaseAllowlist (2) - Transfer validation rules
      ↓
  CMTATBaseERC1404 (3) - ERC-1404 compliance (restrictedTransfer)
      ↓
  CMTATBaseERC20CrossChain (4) - CCIP & ERC-7802 support
      ├── CMTATBaseERC2612 (4) - ERC-2612 Permit + ERC-6357 Multicall [Permit variant]
      └── CMTATBaseERC2771 (5) - Gasless meta-transactions [Standard / UUPS]
              ├── CMTATBaseERC2771Snapshot (5) - + CMTATBaseSnapshot [Snapshot variant]
              ├── CMTATBaseDebtEngine (5) - + CMTATBaseSnapshot + DebtEngineModule [DebtEngine variant]
              ├── CMTATBaseERC1363 (6) - ERC-1363 transferAndCall
              └── CMTATBaseERC7551 (6) - ERC-7551 (eWpG)
```

---

## Key Roles (Access Control)

- `DEFAULT_ADMIN_ROLE` - Admin access (can grant/revoke roles)
- `MINTER_ROLE` - Can mint tokens
- `BURNER_ROLE` - Can burn tokens
- `PAUSER_ROLE` - Can pause/unpause contract
- `ENFORCER_ROLE` - Can freeze/unfreeze addresses