// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Engine === */
import {IDebtEngine, ICMTATDebt, ICMTATCreditEvents} from "../../../interfaces/engine/IDebtEngine.sol";
/* ==== Module === */
import {IDebtEngineModule} from "../../../interfaces/modules/IDebtEngineModule.sol";
/**
 * @title Debt Engine module
 * @dev 
 *
 * Retrieve debt and creditEvents information from a debtEngine
 */
abstract contract DebtEngineModule is IDebtEngineModule {
    /* ============ State Variables ============ */
    bytes32 public constant DEBT_ENGINE_ROLE = keccak256("DEBT_ENGINE_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.DebtEngineModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant DebtEngineModuleStorageLocation = 0xcd6e7f8fdfee4389651c62f4d8dd0b8f0f4b97b1582a8419b0c53664203c6d00;
 
    /* ==== ERC-7201 State Variables === */
    struct DebtModuleStorage {
        IDebtEngine _debtEngine;
    }
        /* ============ Modifier ============ */
    modifier onlyDebtEngineManager {
        _authorizeDebtEngineManagement();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/  

    /* ============  State Restricted Functions ============ */
    /**
    * @notice Sets a new external DebtEngine contract to delegate debt logic.
    * @dev Only callable by accounts with the `DEBT_ROLE`.
    * Emits a {DebtEngine} event upon successful update.
    * @param debtEngine_ The address of the new DebtEngine contract.
    * @custom:access-control
    * - the caller must have the `DEBT_ROLE`.
    */
    function setDebtEngine(
        IDebtEngine debtEngine_
    ) public virtual override(IDebtEngineModule) onlyDebtEngineManager {
        DebtModuleStorage storage $ = _getDebtEngineModuleStorage();
        require($._debtEngine != debtEngine_, CMTAT_DebtEngineModule_SameValue());
        _setDebtEngine($, debtEngine_);
    }

    /* ============ View functions ============ */
    /**
    * @notice Returns the current credit events information.
    * @dev Delegates to the external DebtEngine if set; otherwise returns the base implementation from DebtModule.
    * @return creditEvents_ The current credit events structure.
    * @inheritdoc ICMTATCreditEvents
    */
    function creditEvents() public view virtual override(ICMTATCreditEvents) returns(CreditEvents memory creditEvents_){
        DebtModuleStorage storage $ = _getDebtEngineModuleStorage();
        if(address($._debtEngine) != address(0)){
            creditEvents_ =  $._debtEngine.creditEvents();
        }
    }

    /**
    * @notice Returns the current debt information.
    * @dev Delegates to the external DebtEngine if set; otherwise returns the base implementation from DebtModule.
    * @return debtInformation_ The current debt data structure.
    * @inheritdoc ICMTATDebt
    */
    function debt() public view virtual override(ICMTATDebt) returns(DebtInformation memory debtInformation_){
        DebtModuleStorage storage $ = _getDebtEngineModuleStorage();
        if(address($._debtEngine) != address(0)){
            debtInformation_ =  $._debtEngine.debt();
        } 
    }

    /**
    * @notice Returns the address of the currently active DebtEngine.
    * @return debtEngine_ The contract address of the debt engine in use.
    */
    function debtEngine() public view virtual override(IDebtEngineModule) returns (IDebtEngine debtEngine_) {
        DebtModuleStorage storage $ = _getDebtEngineModuleStorage();
        return $._debtEngine;
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

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ==== Access Control ==== */
    function _authorizeDebtEngineManagement() internal virtual;
    /* ============ ERC-7201 ============ */
    function _getDebtEngineModuleStorage() internal pure returns (DebtModuleStorage storage $) {
        assembly {
            $.slot := DebtEngineModuleStorageLocation
        }
    }
}