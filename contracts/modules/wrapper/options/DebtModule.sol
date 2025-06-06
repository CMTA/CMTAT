//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/* ==== Engine === */
import {IDebtEngine, ICMTATDebt} from "../../../interfaces/engine/IDebtEngine.sol";
import {IDebtModule} from "../../../interfaces/modules/IDebtModule.sol";

/**
 * @title Debt module
 * @dev 
 *
 * Set Debt info
 */
abstract contract DebtModule is AccessControlUpgradeable, IDebtModule {
   
    /* ============ State Variables ============ */
    bytes32 public constant DEBT_ROLE = keccak256("DEBT_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DebtModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DebtModuleStorageLocation = 0xf8a315cc5f2213f6481729acd86e55db7ccc930120ccf9fb78b53dcce75f7c00;
 
    /* ==== ERC-7201 State Variables === */
    struct DebtModuleStorage {
        ICMTATDebt.DebtInformation _debt;
        // Can be used to set a debtEngine
        IDebtEngine _debtEngine;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/    

    /**
    * @inheritdoc IDebtModule
    */
    function setDebt(
          ICMTATDebt.DebtInformation calldata debt_
    ) external virtual override(IDebtModule) onlyRole(DEBT_ROLE) {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        $._debt = debt_;
        emit Debt();
    }

    /**
    * @inheritdoc IDebtModule
    */
    function setDebtInstrument(
          ICMTATDebt.DebtInstrument calldata debtInstrument_
    ) external virtual override(IDebtModule) onlyRole(DEBT_ROLE) {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        $._debt.debtInstrument = debtInstrument_;
        emit DebtInstrumentEvent();
    }
    
    /**
    * @inheritdoc ICMTATDebt
    */
    function debt() public view virtual override(ICMTATDebt) returns(DebtInformation memory DebtInformationResult){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        DebtInformationResult = $._debt;
    }

    /* ============ ERC-7201 ============ */
    function _getDebtModuleStorage() internal pure returns (DebtModuleStorage storage $) {
        assembly {
            $.slot := DebtModuleStorageLocation
        }
    }
}
