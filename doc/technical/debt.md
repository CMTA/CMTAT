# Debt Module

CMTAT provides two deployment versions for representing debt and credit events information on-chain.

| Version | Module | Storage |
|---|---|---|
| `Debt` | `DebtModule` | Directly in the token contract |
| `DebtEngine` | `DebtEngineModule` | External `DebtEngine` contract |

The `DebtEngine` approach reduces the CMTAT contract size (which is near the maximum limit) and allows sharing debt information across multiple token contracts.

See also [CMTAT - Standard for the tokenization of debt instruments using distributed ledger technology](https://cmta.ch/standards/standard-for-the-tokenization-of-debt-instruments-using-distributed-ledger-technology)

## Data Structures

### DebtInformation

```solidity
interface ICMTATDebt {
    struct DebtInformation {
        DebtIdentifier debtIdentifier;
        DebtInstrument debtInstrument;
    }
}
```

### DebtIdentifier

Information on the issuer and other persons involved.

| Field | Type | Description |
|---|---|---|
| `issuerName` | string | Issuer identifier (LEI or equivalent) |
| `issuerDescription` | string | - |
| `guarantor` | string | Guarantor identifier (LEI or equivalent), if applicable |
| `debtHolder` | string | Debtholders representative identifier (LEI or equivalent), if applicable |

### DebtInstrument

Information on the instrument.

| Field | Type | Description |
|---|---|---|
| `interestRate` | uint256 | - |
| `parValue` | uint256 | - |
| `minimumDenomination` | uint256 | - |
| `issuanceDate` | string | - |
| `maturityDate` | string | - |
| `couponPaymentFrequency` | string | - |
| `interestScheduleFormat` | string | Format A: start/end/period; Format B: start/end/day of period; Format C: date1/date2/... |
| `interestPaymentDate` | string | Format A: period between accrual and payment; Format B: specific date |
| `dayCountConvention` | string | - |
| `businessDayConvention` | string | - |
| `currency` | string | - |
| `currencyContract` | address | - |

### CreditEvents

```solidity
interface ICMTATCreditEvents {
    struct CreditEvents {
        bool flagDefault;
        bool flagRedeemed;
        string rating;
    }
}
```

| Field | Type |
|---|---|
| `flagDefault` | bool |
| `flagRedeemed` | bool |
| `rating` | string |

## Functions

| Operation | Module | Function | Role |
|---|---|---|---|
| Read debt info | `DebtModule` / `DebtEngineModule` | `debt()` | - |
| Write debt info | `DebtModule` | `setDebt(...)` | `DEBT_ROLE` |
| Read credit events | `DebtModule` / `DebtEngineModule` | `creditEvents()` | - |
| Write credit events | `DebtModule` | `setCreditEvents(...)` | `DEBT_ROLE` |
| Set DebtEngine | `DebtEngineModule` | `setDebtEngine(address)` | `DEBT_ENGINE_ROLE` |

## DebtEngine Interface

```solidity
interface IDebtEngine is ICMTATDebt, ICMTATCreditEvents {
    // nothing more
}
```

The `DebtEngine` must implement `debt()` and `creditEvents()`. The CMTAT token contract delegates read calls to the external engine; the engine is free to store and manage the data however it wants.

## Deployment Versions

| Contract | Type |
|---|---|
| `CMTATStandaloneDebt` | Standalone (immutable) |
| `CMTATUpgradeableDebt` | Upgradeable (proxy) |
| `CMTATStandaloneDebtEngine` | Standalone with external DebtEngine |
| `CMTATUpgradeableDebtEngine` | Upgradeable with external DebtEngine |

### Feature Matrix

| Feature | `Debt` | `DebtEngine` |
|---|---|---|
| `DebtModule` (on-chain debt data) | ✓ | — |
| `DebtEngineModule` (external engine) | — | ✓ |
| `ERC20CrossChainModule` + `CCIPModule` | — | ✓ |
| ERC-1404 (`restrictedTransferOf`) | — | ✓ (via `CMTATBaseERC20CrossChain`) |
| `ERC2771Module` (meta-transactions) | — | — |
| `CMTATBaseSnapshot` (SnapshotEngine support) | ✓ | ✓ |

Both `Debt` and `DebtEngine` variants include `CMTATBaseSnapshot`, which wires the ERC-20 `_update` hook into an optional external `SnapshotEngine`. This means snapshot functionality is available on these variants without deploying the dedicated `Snapshot` deployment variant. Set the engine with `setSnapshotEngine(address)` (requires `SNAPSHOOTER_ROLE`).

## Compatible DebtEngine Releases

| CMTAT version | DebtEngine |
|---|---|
| CMTAT v3.0.0 | Under development |
| CMTAT v2.5.0 (unaudited) | [DebtEngine v0.2.0](https://github.com/CMTA/DebtEngine/releases/tag/v0.2.0) |
