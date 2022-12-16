//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../interfaces/IDebt.sol";

abstract contract DebtModule is IDebt {
    Debt public debt;
    
    function __DebtModule_init() internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();

         // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
    }

    function __DebtModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    function setGuarantor (string memory guarantor_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        debt.guarantor = guarantor_;
    }

    function setBondHolder (string memory bondHolder_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        debt.bondHolder = bondHolder_;
    }

    function setMaturityDate (string memory maturityDate_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        debt.maturityDate = maturityDate_;
    }

    function setInterestRate (uint256 interestRate_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        debt.interestRate = interestRate_;
    }

    function setParValue (uint256 parValue_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        debt.parValue = parValue_;
    }

    uint256[50] private __gap;
}
