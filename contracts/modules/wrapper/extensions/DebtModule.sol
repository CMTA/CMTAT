//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../security/AuthorizationModule.sol";
import "../../../libraries/Errors.sol";
import "../../../interfaces/engine/IDebtEngine.sol";

abstract contract DebtModule is  AuthorizationModule, IDebtEngine {
    bytes32 public constant DEBT_ROLE = keccak256("DEBT_ROLE");
    IDebtEngine public debtEngine;
    /**
     * @dev Emitted when a rule engine is set.
     */
    event DebtEngine(IDebtEngine indexed newDebtEngine);
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
            debtEngine = debtEngine_;
            emit DebtEngine(debtEngine_);
        }
        

    }

    /*
    * @notice set an authorizationEngine if not already set
    * 
    */
    function setDebtEngine(
        IDebtEngine debtEngine_
    ) external onlyRole(DEBT_ROLE) {
        debtEngine = debtEngine_;
        emit DebtEngine(debtEngine_);
    }

    function debt() external returns(DebtBase memory debtBaseResult){
        if(address(debtEngine) != address(0)){
            debtBaseResult = debtEngine.debt();
        }
    }

    function creditEvents() external returns(CreditEvents memory creditEventsResult){
        if(address(debtEngine) != address(0)){
            creditEventsResult = debtEngine.creditEvents();
        }
    }

    uint256[50] private __gap;
}
