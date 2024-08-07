
// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;
import "../interfaces/IDebtGlobal.sol";
interface IDebtEngine is IDebtGlobal {
    function debt() external view returns (DebtBase memory);
    function creditEvents() external view returns (CreditEvents memory);
    function setDebt(DebtBase calldata debt_) external;
    function setCreditEvents(CreditEvents calldata creditEvents) external;
}

contract DebtEngineMock is IDebtEngine {
    DebtBase private _debt;
    CreditEvents private _creditEvents;

    function debt() external view override returns (DebtBase memory) {
        return _debt;
    }

    function creditEvents() external view override returns (CreditEvents memory) {
        return _creditEvents;
    }

    function setDebt(DebtBase calldata debt_) external override {
        _debt = debt_;
    }

    function setCreditEvents(CreditEvents calldata creditEvents_) external override {
        _creditEvents = creditEvents_;
    }
}