//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Engine === */
import {IDebtEngine, ICMTATDebt} from "../../../interfaces/engine/IDebtEngine.sol";

/**
 * @title Debt module
 * @dev 
 *
 * Set Debt info
 */
abstract contract DebtModule is AuthorizationModule, ICMTATDebt {
    /* ============ State Variables ============ */
    bytes32 public constant DEBT_ROLE = keccak256("DEBT_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DebtModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DebtModuleStorageLocation = 0xf8a315cc5f2213f6481729acd86e55db7ccc930120ccf9fb78b53dcce75f7c00;
 
    /* ==== ERC-7201 State Variables === */
    struct DebtModuleStorage {
        ICMTATDebt.DebtBase _debt;
        // Can be used to set a debtEngine
        IDebtEngine _debtEngine;
    }

    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __DebtModule_init_unchained()
    internal onlyInitializing {
       // nothing to do
    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/    /**
     * @notice Set the debt
     */
    function setDebt(
          ICMTATDebt.DebtBase calldata debt_
    ) external onlyRole(DEBT_ROLE) {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        $._debt = debt_;
    }
    function debt() public view virtual  returns(DebtBase memory debtBaseResult){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        debtBaseResult = $._debt;
    }

    /* ============ ERC-7201 ============ */
    function _getDebtModuleStorage() internal pure returns (DebtModuleStorage storage $) {
        assembly {
            $.slot := DebtModuleStorageLocation
        }
    }

}
