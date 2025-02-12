//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
import {IERC1643CMTAT, IERC1643} from "../../../interfaces/draft-IERC1643CMTAT.sol";

abstract contract BaseModule is AuthorizationModule {
    /* ============ State Variables ============ */
    /** 
    * @notice 
    * Get the current version of the smart contract
    */
    string public constant VERSION = "3.0.0";

 struct Terms {
 	string name;
 	IERC1643.Document doc;
 }
    
    /* ============ Events ============ */
    event Term(Terms indexed newTermIndexed, Terms newTerm);
    event TokenId(string indexed newTokenIdIndexed, string newTokenId);
    event Information(
        string indexed newInformationIndexed,
        string newInformation
    );
    event Flag(uint256 indexed newFlag);
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant BaseModuleStorageLocation = 0xa98e72f7f70574363edb12c42a03ac1feb8cc898a6e0a30f6eefbab7093e0d00;

    /* ==== ERC-7201 State Variables === */
    struct BaseModuleStorage {
            string _tokenId;
            Terms _terms;
            string _information;
    }
    /* ============  Initializer Function ============ */
    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __Base_init_unchained(
        string memory tokenId_,
        IERC1643CMTAT.DocumentInfo memory terms_,
        string memory information_
    ) internal onlyInitializing {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        // tokenId
        _setTokenId($, tokenId_);
        // Terms
        _setTerms($, terms_);
        // Information
        _setInformation($, information_);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function tokenId() public view virtual returns (string memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._tokenId;
    }

    function terms() public view virtual returns (Terms memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._terms;
    }
    function information() public view virtual returns (string memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._information;
    }


    /* ============  Restricted Functions ============ */

    /** 
    * @notice the tokenId will be changed even if the new value is the same as the current one
    */
    function setTokenId(
        string calldata tokenId_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        _setTokenId($, tokenId_);
    }

    /** 
    * @notice The terms will be changed even if the new value is the same as the current one
    */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) public onlyRole(DEFAULT_ADMIN_ROLE) {
		BaseModuleStorage storage $ = _getBaseModuleStorage();
        _setTerms($, terms_);
    }


    /** 
    * @notice The information will be changed even if the new value is the same as the current one
    */
    function setInformation(
        string calldata information_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        _setInformation($, information_);
    }



    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /** 
    * @dev the tokenId will be changed even if the new value is the same as the current one
    */
    function _setTokenId(
        BaseModuleStorage storage $, string memory tokenId_
    ) internal  {
        $._tokenId = tokenId_;
        emit TokenId(tokenId_, tokenId_);
    }

    /** 
    * @dev The terms will be changed even if the new value is the same as the current one
    */
    function _setTerms(BaseModuleStorage storage $, IERC1643CMTAT.DocumentInfo memory terms_) internal {
		// Terms/Document name
        $._terms.name = terms_.name;
        // Document
        $._terms.doc.documentHash  = terms_.documentHash;
        $._terms.doc.uri = terms_.uri;
        $._terms.doc.lastModified = block.timestamp;
		// Event
        emit Term($._terms, $._terms);
    }

    /** 
    * @dev The terms will be changed even if the new value is the same as the current one
    */
    function _setInformation(BaseModuleStorage storage $, string memory information_) internal {
        $._information  = information_;
        emit Information(information_, information_);
    }


    /* ============ ERC-7201 ============ */
    function _getBaseModuleStorage() private pure returns (BaseModuleStorage storage $) {
        assembly {
            $.slot := BaseModuleStorageLocation
        }
    }

}
