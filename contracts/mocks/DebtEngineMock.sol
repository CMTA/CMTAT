
// SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;
import {IDebtEngine} from "../interfaces/engine/IDebtEngine.sol";
interface IDebtEngineMock is IDebtEngine  {
    function setDebt(DebtBase calldata debt_) external;
    function setCreditEvents(CreditEvents calldata creditEvents) external;
}

/*
* @title a DebtEngine mock for testing, not suitable for production
*/
contract DebtEngineMock is IDebtEngineMock {
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