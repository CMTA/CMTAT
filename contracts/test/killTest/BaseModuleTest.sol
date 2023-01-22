//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../modules/security/AuthorizationModule.sol";
import "../../modules/security/OnlyDelegateCallModule.sol";

/**
@title A BaseModule version only for TESTING
@dev This version has removed the check of access control on the kill function
The only remaining protection is the call to the modifier onlyDelegateCall
*/
abstract contract BaseModuleTest is
    Initializable,
    AuthorizationModule,
    OnlyDelegateCallModule
{
    // @dev we removed the access control to check onlyDelegateCall
    /// @custom:oz-upgrades-unsafe-allow selfdestruct
    function kill() public onlyDelegateCall(deployedWithProxy) {
        selfdestruct(payable(_msgSender()));
    }

    //******* Code from BaseModule, not modified *******/

    bool internal deployedWithProxy;
    /* Events */
    event TermSet(string indexed newTerm);
    event TokenIdSet(string indexed newTokenId);
    event InformationSet(string indexed newInformation);
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

        /* Wrapper */
        __AuthorizationModule_init_unchained(admin);

        /* own function */
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
        emit TokenIdSet(tokenId_);
    }

    function setTerms(
        string memory terms_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        terms = terms_;
        emit TermSet(terms_);
    }

    function setInformation(
        string memory information_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        information = information_;
        emit InformationSet(information_);
    }

    function setFlag(uint256 flag_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        flag = flag_;
        emit FlagSet(flag_);
    }

    uint256[50] private __gap;
}
