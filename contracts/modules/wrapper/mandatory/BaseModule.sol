//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../optional/AuthorizationModule.sol";
import "../../../modules/security/OnlyDelegateCallModule.sol";

abstract contract BaseModule is AuthorizationModule, OnlyDelegateCallModule {
    bool internal deployedWithProxy;
    /* Events */
    event TermSet(string indexed newTerm);
    event TokenIdSet(string indexed newTokenId);

    /* Variables */
    string public tokenId;
    string public terms;

    /* Initializers */
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __Base_init(
        string memory tokenId_,
        string memory terms_
    ) internal onlyInitializing {
         /* OpenZeppelin */
        __Context_init_unchained();
         // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();

         /* Wrapper */
        __AuthorizationModule_init_unchained();
        
        /* own function */
        __Base_init_unchained(tokenId_, terms_);
    }

    function __Base_init_unchained(
        string memory tokenId_,
        string memory terms_
    ) internal onlyInitializing {
        tokenId = tokenId_;
        terms = terms_;
    }

    /* Methods */
    function setTokenId(string memory tokenId_)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        tokenId = tokenId_;
        emit TokenIdSet(tokenId_);
    }

    function setTerms(string memory terms_)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        terms = terms_;
        emit TermSet(terms_);
    }

    /// @custom:oz-upgrades-unsafe-allow selfdestruct
    function kill() public onlyRole(DEFAULT_ADMIN_ROLE) onlyDelegateCall(deployedWithProxy) {
        selfdestruct(payable(_msgSender()));
    }

    uint256[50] private __gap;
}
