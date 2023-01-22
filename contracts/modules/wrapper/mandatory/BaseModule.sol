//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../security/AuthorizationModule.sol";
import "../../../modules/security/OnlyDelegateCallModule.sol";

abstract contract BaseModule is AuthorizationModule, OnlyDelegateCallModule {
    bool internal deployedWithProxy;
    /* Events */
    event TermSet(string indexed newTermIndexed, string newTerm);
    event TokenIdSet(string indexed newTokenIdIndexed, string newTokenId);
    event InformationSet(
        string indexed newInformationIndexed,
        string newInformation
    );
    event FlagSet(uint256 indexed newFlag);

    /* Variables */
    string public tokenId;
    string public terms;
    string public information;
    uint256 public flag;

    /* Initializers */
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __Base_init(
        string memory tokenId_,
        string memory terms_,
        string memory information_,
        uint256 flag_,
        address admin
    ) internal onlyInitializing {
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
        __Base_init_unchained(tokenId_, terms_, information_, flag_);
    }

    function __Base_init_unchained(
        string memory tokenId_,
        string memory terms_,
        string memory information_,
        uint256 flag_
    ) internal onlyInitializing {
        tokenId = tokenId_;
        terms = terms_;
        information = information_;
        flag = flag_;
    }

    /* Methods */
    function setTokenId(
        string memory tokenId_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenId = tokenId_;
        emit TokenIdSet(tokenId_, tokenId_);
    }

    function setTerms(
        string memory terms_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        terms = terms_;
        emit TermSet(terms_, terms_);
    }

    function setInformation(
        string memory information_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        information = information_;
        emit InformationSet(information_, information_);
    }

    function setFlag(uint256 flag_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        flag = flag_;
        emit FlagSet(flag_);
    }

    /**
    @notice destroys the contract and send the remaining ethers in the contract to the sender
    Warning: the operation is irreversible, be careful
    */
    /// @custom:oz-upgrades-unsafe-allow selfdestruct
    function kill()
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        onlyDelegateCall(deployedWithProxy)
    {
        selfdestruct(payable(_msgSender()));
    }

    uint256[50] private __gap;
}
