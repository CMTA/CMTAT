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
 * Retrieve debt and creditEvents information from a debtEngine
 */
abstract contract DebtEngineModule is AuthorizationModule, ICMTATDebt {
    error CMTAT_DebtEngineModule_SameValue();
    /* ============ State Variables ============ */
    bytes32 public constant DEBT_ROLE = keccak256("DEBT_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DebtEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DebtEngineModuleStorageLocation = 0xf8a315cc5f2213f6481729acd86e55db7ccc930120ccf9fb78b53dcce75f7c00;
 
    /* ==== ERC-7201 State Variables === */
    struct DebtEngineModuleStorage {
        IDebtEngine _debtEngine;
        ICMTATDebt.DebtBase _debt;
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
    function __DebtEngineModule_init_unchained(IDebtEngine debtEngine_)
    internal onlyInitializing {
        if (address(debtEngine_) != address (0)) {
            DebtEngineModuleStorage storage $ = _getDebtEngineModuleStorage();
            $._debtEngine = debtEngine_;
            emit DebtEngine(debtEngine_);
        }
        

    }
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function debtEngine() public view virtual returns (IDebtEngine) {
        DebtEngineModuleStorage storage $ = _getDebtEngineModuleStorage();
        return $._debtEngine;
    }

    /**
    * @inheritdoc ICMTATDebt
    */
    function debt() public view virtual returns(DebtBase memory debtBaseResult){
        DebtEngineModuleStorage storage $ = _getDebtEngineModuleStorage();
        if(address($._debtEngine) != address(0)){
            debtBaseResult =  $._debtEngine.debt();
        } 
    }

    /**
    * @inheritdoc ICMTATDebt
    */
    function creditEvents() public view virtual returns(CreditEvents memory creditEventsResult){
        DebtEngineModuleStorage storage $ = _getDebtEngineModuleStorage();
        if(address($._debtEngine) != address(0)){
            creditEventsResult =  $._debtEngine.creditEvents();
        }
    }

    /* ============  Restricted Functions ============ */
    /*
    * @notice set a DebtEngine
    * 
    */
    function setDebtEngine(
        IDebtEngine debtEngine_
    ) external virtual onlyRole(DEBT_ROLE) {
        DebtEngineModuleStorage storage $ = _getDebtEngineModuleStorage();
        require($._debtEngine != debtEngine_, CMTAT_DebtEngineModule_SameValue());
        _setDebtEngine($, debtEngine_);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setDebtEngine(
        DebtEngineModuleStorage storage $, IDebtEngine debtEngine_
    ) internal {
        $._debtEngine = debtEngine_;
        emit DebtEngine(debtEngine_);
    }

    
    /* ============ ERC-7201 ============ */
    function _getDebtEngineModuleStorage() internal pure returns (DebtEngineModuleStorage storage $) {
        assembly {
            $.slot := DebtEngineModuleStorageLocation
        }
    }

}
