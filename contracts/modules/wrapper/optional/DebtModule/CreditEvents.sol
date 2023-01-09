//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "../../../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../../interfaces/IDebt.sol";
import "../../optional/AuthorizationModule.sol";

abstract contract CreditEvents is IDebtGlobal,  Initializable, ContextUpgradeable, AuthorizationModule {
    bytes32 public constant DEBT_CREDIT_EVENT_ROLE = keccak256("DEBT_CREDIT_EVENT_ROLE");

    CreditEvents public creditEvents;

    /* Events */
    event FlagDefaultSet(bool indexed newFlagDefault);
    event FlagRedeemedSet(bool indexed FlagRedeemed);
    event RatingSet(uint256 indexed newRating);
    
    function __CreditEvents_init() internal onlyInitializing {
        /* OpenZeppelin */
        __Context_init_unchained();

         // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();

        /* own function */
        __CreditEvents_init_unchained();
    }

    function __CreditEvents_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    function setCreditEvent(bool flagDefault_, bool flagRedeemed_, uint256 rating_) public onlyRole("DEBT_CREDIT_EVENT_ROLE") {
        // setGuarantor
        creditEvents = 
        (CreditEvents(flagDefault_, flagRedeemed_, rating_));
        emit FlagDefaultSet(flagDefault_);
        emit FlagRedeemedSet(flagRedeemed_ );
        emit RatingSet(rating_);
    }


    function setFlagDefault (bool flagDefault_) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        require(flagDefault_ != creditEvents.flagDefault, "Same value");
        creditEvents.flagDefault = flagDefault_;
        emit FlagDefaultSet(flagDefault_);
    }

    function setFlagRedeemed (bool flagRedeemed_) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        require(flagRedeemed_ != creditEvents.flagRedeemed, "Same value");
        creditEvents.flagRedeemed = flagRedeemed_ ;
        emit FlagRedeemedSet(flagRedeemed_ );
    }

    function setRating (uint256 rating_) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        require(rating_  != creditEvents.rating, "Same value");
        creditEvents.rating = rating_;
        emit RatingSet(rating_);
    }


    uint256[50] private __gap;
}
