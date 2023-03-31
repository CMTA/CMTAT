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
    event creditEventFlag(uint256 indexed newFlag);
    event FlagDefaultSet(uint256 indexed newFlagDefault);
    event FlagRedeemedSet(uint256 indexed newFlagRedeemed);
    event RatingSet(string indexed newRatingIndexed, string newRating);

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
        uint256 flag_,
        string memory rating_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        creditEvents = (CreditEvents(flag_, rating_));
        emit FlagDefaultSet(flag_ & uint256(CREDIT_EVENT_FLAG.FLAG_DEFAULT));
        emit FlagRedeemedSet(flag_ & uint256(CREDIT_EVENT_FLAG.FLAG_REDEEMED));
        emit RatingSet(rating_, rating_);
    }
    
    function readCreditFlag(uint256 indexFromRight) external returns (bool) {
        return (creditEvents.flag & (1 << indexFromRight)) > 0;
    }

    function modifyBit(uint256 number, uint256 position, uint256 binary) internal returns (uint256){
        uint256 mask = 1 << position;
        return (( number & mask) | (binary << position));
    }

    function setFlagDefault(
        bool flagDefault_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        require(uint256((creditEvents.flag & uint256(CREDIT_EVENT_FLAG.FLAG_DEFAULT))) != flagDefault_ , "Same value");
        creditEvents.flag = modifyBit (creditEvents.flag, CREDIT_EVENT_FLAG.FLAG_DEFAULT, flagDefault_);
        emit FlagDefaultSet(uint256(flagDefault_));
    }

    function setFlagRedeemed(
        bool flagRedeemed_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        require((creditEvents.flag & uint256(CREDIT_EVENT_FLAG.FLAG_REDEEMED)) != flagRedeemed_ , "Same value");
        creditEvents.flag = modifyBit (creditEvents.flag, CREDIT_EVENT_FLAG.FLAG_REDEEMED, flagRedeemed_);
        emit FlagRedeemedSet(uint256(flagRedeemed_));
    }

    function setRating(
        string memory rating_
    ) public onlyRole(DEBT_CREDIT_EVENT_ROLE) {
        creditEvents.rating = rating_;
        emit RatingSet(rating_, rating_);
    }

    uint256[50] private __gap;
}
