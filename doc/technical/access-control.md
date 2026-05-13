# Access Control (RBAC)

CMTAT uses Role-Based Access Control (RBAC) from OpenZeppelin. Access control is modular: each wrapper module defines its required roles and declares `virtual` authorization hooks. The base contract `CMTATBaseAccessControl` provides the concrete implementation using `AccessControl`.

The `AccessControlModule` overrides `hasRole` so that the `DEFAULT_ADMIN_ROLE` holder has all roles by default.

See also [docs.openzeppelin.com - AccessControl](https://docs.openzeppelin.com/contracts/5.x/api/access#AccessControl)

## Architecture

**Wrapper modules** define:
- The roles required to restrict their functions
- Virtual `authorize<RoleName>` functions that must be overridden in the base module

**CMTAT base modules** override those virtual functions and enforce RBAC. This separation allows replacing the access control mechanism without modifying the feature modules.

## Role List

| Role | Defined in | 32-byte Identifier |
|---|---|---|
| `DEFAULT_ADMIN_ROLE` | OpenZeppelin AccessControl | `0x0000000000000000000000000000000000000000000000000000000000000000` |
| `BURNER_ROLE` | BurnModule | `0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848` |
| `MINTER_ROLE` | MintModule | `0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6` |
| `ENFORCER_ROLE` | EnforcementModule | `0x973ef39d76cc2c6090feab1c030bec6ab5db557f64df047a4c4f9b5953cf1df3` |
| `PAUSER_ROLE` | PauseModule | `0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a` |
| `SNAPSHOOTER_ROLE` | SnapshotEngineModule | `0x809a0fc49fc0600540f1d39e23454e1f6f215bc7505fa22b17c154616570ddef` |
| `DOCUMENT_ROLE` | DocumentEngineModule | `0xdd7c9aafbb91d54fb2041db1d5b172ea665309b32f5fffdbddf452802a1e3b20` |
| `EXTRA_INFORMATION_ROLE` | ExtraInformationModule | `0x921df7a58eb4ea112afa962b8186161404ecda2e8fe97f8246026d02ad1a74b7` |
| `ERC20ENFORCER_ROLE` | ERC20EnforcementModule | `0xd62f75bf68b069bc8e2abd495a949fafec67a4e5a5b7cb36aedf0dd51eec7e72` |
| `ALLOWLIST_ROLE` | AllowlistModule | `0x26a560d834a19637eccba4611bbc09fb32970bb627da0a70f14f83fdc9822cbc` |
| `DEBT_ROLE` | DebtModule | `0xc6f3350ab30f55ce45863160fc345c1663d4633fe7cacfd3b9bbb6420a9147f8` |
| `DEBT_ENGINE_ROLE` | DebtEngineModule | `0x516b2a17ebe2d0badac282ee8b39b7f1c94deb40fe902ce0db99741f01cae093` |
| `CROSS_CHAIN_ROLE` | ERC20CrossChainModule | `0x620d362b92b6ef580d4e86c5675d679fe08d31dff47b72f281959a4eecdd036a` |
| `BURNER_FROM_ROLE` | ERC20CrossChainModule | `0x5bfe08abba057c54e6a28bce27ce8c53eb21d7a94376a70d475b5dee60b6c4e2` |
| `BURNER_SELF_ROLE` | ERC20CrossChainModule | `0x13d9f3ea33477b975af6cd01437366c28412d5bd9b872fa0fc25bd3a160683af` |

## Role by Module

| Module | Function | Role Required |
|---|---|---|
| **ERC20BaseModule** | `setName(string)` | `DEFAULT_ADMIN_ROLE` |
| | `setSymbol(string)` | `DEFAULT_ADMIN_ROLE` |
| **ERC20BurnModule** | `burn(address, uint256, bytes)` | `BURNER_ROLE` |
| | `batchBurn(address[], uint256[], bytes)` | `BURNER_ROLE` |
| **ERC20MintModule** | `mint(address, uint256, bytes)` | `MINTER_ROLE` |
| | `batchMint(address[], uint256[])` | `MINTER_ROLE` |
| | `batchTransfer(address[], uint256[])` | `MINTER_ROLE` |
| **EnforcementModule** | `setAddressFrozen(address, bool)` | `ENFORCER_ROLE` |
| | `batchSetAddressFrozen(address[], bool[])` | `ENFORCER_ROLE` |
| **PauseModule** | `pause()` | `PAUSER_ROLE` |
| | `unpause()` | `PAUSER_ROLE` |
| | `deactivateContract()` | `DEFAULT_ADMIN_ROLE` |
| **ERC20EnforcementModule** | `forcedTransfer(address, address, uint256)` | `DEFAULT_ADMIN_ROLE` |
| | `freezePartialTokens(address, uint256)` | `ERC20ENFORCER_ROLE` |
| | `unfreezePartialTokens(address, uint256)` | `ERC20ENFORCER_ROLE` |
| **SnapshotEngineModule** | `setSnapshotEngine(address)` | `SNAPSHOOTER_ROLE` |
| **DocumentEngineModule** | `setDocumentEngine(address)` | `DOCUMENT_ROLE` |
| **AllowlistModule** | `setAddressAllowlist(address, bool)` | `ALLOWLIST_ROLE` |
| | `batchSetAddressAllowlist(address[], bool[])` | `ALLOWLIST_ROLE` |
| **DebtModule** | `setDebt(...)` | `DEBT_ROLE` |
| | `setCreditEvents(...)` | `DEBT_ROLE` |
| **DebtEngineModule** | `setDebtEngine(address)` | `DEBT_ENGINE_ROLE` |
| **ERC20CrossChain** | `crosschainMint(address, uint256)` | `CROSS_CHAIN_ROLE` |
| | `crosschainBurn(address, uint256)` | `CROSS_CHAIN_ROLE` |
| | `burnFrom(address, uint256)` | `BURNER_FROM_ROLE` |
| | `burn(uint256)` | `BURNER_SELF_ROLE` |
| **CCIPModule** | `setCCIPAdmin(address)` | `DEFAULT_ADMIN_ROLE` |
| **BaseCommon** | `burnAndMint(address, address, uint256, uint256, bytes)` | `BURNER_ROLE` + `MINTER_ROLE` |

## Input Guards

- `EnforcementModule.setAddressFrozen(...)` and `batchSetAddressFrozen(...)` reject `address(0)` (`CMTAT_Enforcement_ZeroAddressNotAllowed`).
- `ERC20EnforcementModule.freezePartialTokens(...)` and `unfreezePartialTokens(...)` reject `address(0)` (`CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed`).

## Key Management

Access to the `DEFAULT_ADMIN_ROLE` key must be adequately restricted. Access to any proxy contract must be segregated from the token contract.

### UUPS Proxy

For the UUPS deployment version there is no segregation between admin rights and the proxy upgrade authority. A compromise of `DEFAULT_ADMIN_ROLE` could allow an attacker to swap the implementation contract. Consider using a multisig or timelock for the admin account.

## Transferring Admin

To transfer admin to a new address:

1. Call `grantRole(DEFAULT_ADMIN_ROLE, newAdmin)` from the current admin.
2. Call `renounceRole(DEFAULT_ADMIN_ROLE, currentAdmin)` to remove the current admin.

The new admin can also call `revokeRole` to remove the old admin. Multiple concurrent admins are supported.
