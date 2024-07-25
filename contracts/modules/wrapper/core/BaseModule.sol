//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// required OZ imports here
import "../../security/AuthorizationModule.sol";
import "../../../libraries/Errors.sol";
import "../../../interfaces/draft-IERC1643.sol";
abstract contract BaseModule is IERC1643, AuthorizationModule {
    /** 
    * @notice 
    * Get the current version of the smart contract
    */
    string public constant VERSION = "2.4.1";
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
    // additional attribute to store information as an uint256
    uint256 public flag;
    IERC1643 DocumentEngine;



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
    /** 
    * @notice the tokenId will be changed even if the new value is the same as the current one
    */
    function setTokenId(
        string calldata tokenId_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        tokenId = tokenId_;
        emit TokenId(tokenId_, tokenId_);
    }

    /** 
    * @notice The terms will be changed even if the new value is the same as the current one
    */
    function setTerms(
        string calldata terms_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        terms = terms_;
        emit Term(terms_, terms_);
    }

    /** 
    * @notice The information will be changed even if the new value is the same as the current one
    */
    function setInformation(
        string calldata information_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        information = information_;
        emit Information(information_, information_);
    }

    function getDocument(bytes32 _name) public view returns (string memory, bytes32, uint256){
        if(address(DocumentEngine) != address(0)){
            return DocumentEngine.getDocument( _name);
        } else{
            return ("",0x0, 0);
        }
    }

    function getAllDocuments() public view returns (bytes32[] memory documents){
        if(address(DocumentEngine) != address(0)){
            documents =  DocumentEngine.getAllDocuments();
        }
    }

    uint256[50] private __gap;
}
