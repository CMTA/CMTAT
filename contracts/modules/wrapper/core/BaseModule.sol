//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// required OZ imports here
import "../../../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../security/AuthorizationModule.sol";
import "../../../libraries/Errors.sol";

abstract contract BaseModule is AuthorizationModule {
    /*
    @notice 
    Get the current version of the smart contract
    */
    string public constant VERSION = "2.3.1";
    /* Events */
    event Term(string indexed newTermIndexed, string newTerm);
    event TokenId(string indexed newTokenIdIndexed, string newTokenId);
    event Information(
        string indexed newInformationIndexed,
        string newInformation
    );
    event Flag(uint256 indexed newFlag);

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
    /*
    @notice the tokenId will be changed even if the new value is the same as the current one
    */
    function setTokenId(
        string calldata tokenId_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenId = tokenId_;
        emit TokenId(tokenId_, tokenId_);
    }

    /*
    @notice The terms will be changed even if the new value is the same as the current one
    */
    function setTerms(
        string calldata terms_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        terms = terms_;
        emit Term(terms_, terms_);
    }

    /*
    @notice The information will be changed even if the new value is the same as the current one
    */
    function setInformation(
        string calldata information_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        information = information_;
        emit Information(information_, information_);
    }

    /*
    @notice The call will be reverted if the new value of flag is the same as the current one
    */
    function setFlag(uint256 flag_) public onlyRole(DEFAULT_ADMIN_ROLE) {
        if (flag == flag_) {
            revert Errors.CMTAT_BaseModule_SameValue();
        }
        flag = flag_;
        emit Flag(flag_);
    }

    uint256[50] private __gap;
}
