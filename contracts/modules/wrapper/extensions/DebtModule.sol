//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {Errors} from "../../../libraries/Errors.sol";
import {IDebtEngine} from "../../../interfaces/engine/IDebtEngine.sol";

/**
 * @title Debt module
 * @dev 
 *
 * Retrieve debt and creditEvents information from a debtEngine
 */
abstract contract DebtModule is AuthorizationModule, IDebtEngine {
    /* ============ State Variables ============ */
    bytes32 public constant DEBT_ROLE = keccak256("DEBT_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DebtModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DebtModuleStorageLocation = 0xf8a315cc5f2213f6481729acd86e55db7ccc930120ccf9fb78b53dcce75f7c00;
 
    /* ==== ERC-7201 State Variables === */
    struct DebtModuleStorage {
        IDebtEngine _debtEngine;
    }
    /* ============ Events ============ */
    /**
    * @dev Emitted when a rule engine is set.
    */
    event DebtEngine(IDebtEngine indexed newDebtEngine);


    /* ============  Initializer Function ============ */
    /**
     * @dev
     *
     * - The grant to the admin role is done by AccessControlDefaultAdminRules
     * - The control of the zero address is done by AccessControlDefaultAdminRules
     *
     */
    function __DebtModule_init_unchained(IDebtEngine debtEngine_)
    internal onlyInitializing {
        if (address(debtEngine_) != address (0)) {
            DebtModuleStorage storage $ = _getDebtModuleStorage();
            $._debtEngine = debtEngine_;
            emit DebtEngine(debtEngine_);
        }
        

    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function debtEngine() public view virtual returns (IDebtEngine) {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        return $._debtEngine;
    }

    function debt() public view returns(DebtBase memory debtBaseResult){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        if(address($._debtEngine) != address(0)){
            debtBaseResult =  $._debtEngine.debt();
        }
    }

    function creditEvents() public view returns(CreditEvents memory creditEventsResult){
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        if(address($._debtEngine) != address(0)){
            creditEventsResult =  $._debtEngine.creditEvents();
        }
    }

    /* ============  Restricted Functions ============ */
    /*
    * @notice set an authorizationEngine if not already set
    * 
    */
    function setDebtEngine(
        IDebtEngine debtEngine_
    ) external onlyRole(DEBT_ROLE) {
        DebtModuleStorage storage $ = _getDebtModuleStorage();
        if ($._debtEngine == debtEngine_){
            revert Errors.CMTAT_DebtModule_SameValue();
        }
        _setDebtEngine($, debtEngine_);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setDebtEngine(
        DebtModuleStorage storage $, IDebtEngine debtEngine_
    ) internal {
        $._debtEngine = debtEngine_;
        emit DebtEngine(debtEngine_);
    }

    
    /* ============ ERC-7201 ============ */
    function _getDebtModuleStorage() private pure returns (DebtModuleStorage storage $) {
        assembly {
            $.slot := DebtModuleStorageLocation
        }
    }

}
