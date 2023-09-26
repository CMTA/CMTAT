//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import "../../../../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../../../interfaces/IDebtGlobal.sol";
import "../../../security/AuthorizationModule.sol";

import "../../../../libraries/Errors.sol";

abstract contract CreditEventsModule is
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

    function __CreditEvents_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /** 
    * @notice Set all attributes of creditEvents
    * The values of all attributes will be changed even if the new values are the same as the current ones
    */
    function setCreditEvents(
        bool flagDefault_,
        bool flagRedeemed_,
        string calldata rating_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        creditEvents = (CreditEvents(flagDefault_, flagRedeemed_, rating_));
        emit FlagDefault(flagDefault_);
        emit FlagRedeemed(flagRedeemed_);
        emit Rating(rating_, rating_);
    }

    /** 
    * @notice The call will be reverted if the new value of flagDefault is the same as the current one
    */
    function setFlagDefault(
        bool flagDefault_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        if (flagDefault_ == creditEvents.flagDefault) {
            revert Errors.CMTAT_DebtModule_SameValue();
        }
        creditEvents.flagDefault = flagDefault_;
        emit FlagDefault(flagDefault_);
    }

    /** 
    * @notice The call will be reverted if the new value of flagRedeemed is the same as the current one
    */
    function setFlagRedeemed(
        bool flagRedeemed_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        if (flagRedeemed_ == creditEvents.flagRedeemed) {
            revert Errors.CMTAT_DebtModule_SameValue();
        }
        creditEvents.flagRedeemed = flagRedeemed_;
        emit FlagRedeemed(flagRedeemed_);
    }

    /** 
    * @notice The rating will be changed even if the new value is the same as the current one
    */
    function setRating(
        string calldata rating_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        creditEvents.rating = rating_;
        emit Rating(rating_, rating_);
    }

    uint256[50] private __gap;
}
