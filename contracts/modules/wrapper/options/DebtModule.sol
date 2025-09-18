// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Engine === */
import {IDebtEngine, ICMTATDebt, ICMTATCreditEvents} from "../../../interfaces/engine/IDebtEngine.sol";
import {IDebtModule} from "../../../interfaces/modules/IDebtModule.sol";

/**
 * @title Debt module
 * @dev 
 *
 * Set Debt and Credit Events info
 */
abstract contract DebtModule is IDebtModule {
    /* ============ State Variables ============ */
    bytes32 public constant DEBT_ROLE = keccak256("DEBT_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DebtModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DebtModuleStorageLocation = 0xf8a315cc5f2213f6481729acd86e55db7ccc930120ccf9fb78b53dcce75f7c00;
 
    /* ==== ERC-7201 State Variables === */
    struct DebtModuleStorage {
        ICMTATDebt.DebtInformation _debt;
        ICMTATCreditEvents.CreditEvents _creditEvents;
        // Can be used to set a debtEngine
        IDebtEngine _debtEngine;
    }

    /* ============ Modifier ============ */
    modifier onlyDebtManager {
        _authorizeDebtManagement();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/  
    /* ============ State functions ============ */
    /**
    * @dev The values of all attributes will be changed even if the new values are the same as the current ones
    * @inheritdoc IDebtModule
    * @custom:access-control
    * - the caller must have the `DEBT_ROLE`.
    */
    function setCreditEvents(
       CreditEvents calldata creditEvents_
    ) public onlyDebtManager {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        $._creditEvents = creditEvents_;
        emit CreditEventsLogEvent();
    }  

    /**
    * @inheritdoc IDebtModule
    * @custom:access-control
    * - the caller must have the `DEBT_ROLE`.
    */
    function setDebt(
          ICMTATDebt.DebtInformation calldata debt_
    ) public virtual override(IDebtModule) onlyDebtManager {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        $._debt = debt_;
        emit DebtLogEvent();
    }

    /**
    * @inheritdoc IDebtModule
    * @custom:access-control
    * - the caller must have the `DEBT_ROLE`.
    */
    function setDebtInstrument(
          ICMTATDebt.DebtInstrument calldata debtInstrument_
    ) public virtual override(IDebtModule) onlyDebtManager {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        $._debt.debtInstrument = debtInstrument_;
        emit DebtInstrumentLogEvent();
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc ICMTATCreditEvents
    */
    function creditEvents() public view virtual override(ICMTATCreditEvents) returns(CreditEvents memory creditEvents_){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        creditEvents_ = $._creditEvents;
    }

    /**
    * @inheritdoc ICMTATDebt
    */
    function debt() public view virtual override(ICMTATDebt) returns(DebtInformation memory debtInformation_){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        debtInformation_ = $._debt;
    }
    
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control ==== */
    function _authorizeDebtManagement() internal virtual;
    /* ============ ERC-7201 ============ */
    function _getDebtModuleStorage() internal pure returns (DebtModuleStorage storage $) {
        assembly {
            $.slot := DebtModuleStorageLocation
        }
    }
}