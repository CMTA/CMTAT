//SPDX-License-Identifier: MPL-2.0
import "./IDebtEngine.sol";
import "./IRuleEngine.sol";
import "./IAuthorizationEngine.sol";
import "./draft-IERC1643.sol";

pragma solidity ^0.8.20;

/**
* @notice interface to represent debt tokens
*/
interface IEngine {
    struct Engine {
        IRuleEngine ruleEngine;
        IDebtEngine debtEngine;
        IAuthorizationEngine authorizationEngine;
        IERC1643 documentEngine;
    }


}
