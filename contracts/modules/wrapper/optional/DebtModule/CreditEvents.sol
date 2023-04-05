//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../../interfaces/IDebtGlobal.sol";
import "../../../security/AuthorizationModule.sol";

abstract contract CreditEvents is
    IDebtGlobal,
    Initializable,
    ContextUpgradeable,
    AuthorizationModule
{
    CreditEvents public creditEvents;

    /* Events */
    event FlagDefault(bool indexed newFlagDefault);
    event FlagRedeemed(bool indexed newFlagRedeemed);
    event Rating(string indexed newRatingIndexed, string newRating);

    function __CreditEvents_init(address admin) internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();

        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();

        /* CMTAT modules */
        // Security
        __AuthorizationModule_init_unchained(admin);

        // own function
        __CreditEvents_init_unchained();
    }

    function __CreditEvents_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    function setCreditEvents(
        bool flagDefault_,
        bool flagRedeemed_,
        string memory rating_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        creditEvents = (CreditEvents(flagDefault_, flagRedeemed_, rating_));
        emit FlagDefault(flagDefault_);
        emit FlagRedeemed(flagRedeemed_);
        emit Rating(rating_, rating_);
    }

    function setFlagDefault(
        bool flagDefault_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        require(flagDefault_ != creditEvents.flagDefault, "Same value");
        creditEvents.flagDefault = flagDefault_;
        emit FlagDefault(flagDefault_);
    }

    function setFlagRedeemed(
        bool flagRedeemed_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        require(flagRedeemed_ != creditEvents.flagRedeemed, "Same value");
        creditEvents.flagRedeemed = flagRedeemed_;
        emit FlagRedeemed(flagRedeemed_);
    }

    function setRating(
        string memory rating_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        creditEvents.rating = rating_;
        emit Rating(rating_, rating_);
    }

    uint256[50] private __gap;
}
