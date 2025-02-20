//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Tokenization === */
import {IERC1643CMTAT, IERC1643} from "../../../interfaces/tokenization/draft-IERC1643CMTAT.sol";
import {IERC3643Base} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {ICMTATBase} from "../../../interfaces/tokenization/ICMTAT.sol";
import {IERC7551Base} from "../../../interfaces/tokenization/draft-IERC7551.sol";
abstract contract BaseModule is IERC3643Base, IERC7551Base, ICMTATBase, AuthorizationModule {
    /* ============ State Variables ============ */
    /** 
    * @notice 
    * Get the current version of the smart contract
    */
    string private constant VERSION = "3.0.0";
    /* ============ Events ============ */
    event Information(
        string indexed newInformationIndexed,
        string newInformation
    );
    event Metadata(
        string indexed newMetaDataIdexed,
        string newMetaData
    );
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.BaseModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant BaseModuleStorageLocation = 0xa98e72f7f70574363edb12c42a03ac1feb8cc898a6e0a30f6eefbab7093e0d00;

    /* ==== ERC-7201 State Variables === */
    struct BaseModuleStorage {
            string _tokenId;
            Terms _terms;
            string _information;
            string _metadata;
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
    /**
    * @notice ERC-3643 version function
    */
    function version() public view virtual override(IERC3643Base) returns (string memory) {
       return VERSION;
    }
    function tokenId() public view  virtual override(ICMTATBase) returns (string memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._tokenId;
    }

    function terms() public view virtual override(ICMTATBase)  returns (Terms memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._terms;
    }
    function information() public view virtual returns (string memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._information;
    }

    function metaData() public view virtual override(IERC7551Base) returns (string memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._metadata;
    }


    /* ============  Restricted Functions ============ */

    /** 
    * @notice the tokenId will be changed even if the new value is the same as the current one
    */
    function setTokenId(
        string calldata tokenId_
    ) public virtual override(ICMTATBase)  onlyRole(DEFAULT_ADMIN_ROLE) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        _setTokenId($, tokenId_);
    }

    /** 
    * @notice The terms will be changed even if the new value is the same as the current one
    */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) public virtual override(ICMTATBase) onlyRole(DEFAULT_ADMIN_ROLE) {
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



    /** 
    * @notice The information will be changed even if the new value is the same as the current one
    */
    function setMetaData(
        string calldata metadata_
    ) public override(IERC7551Base) onlyRole(DEFAULT_ADMIN_ROLE) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        _setMetaData($,  metadata_);
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /** 
    * @dev the tokenId will be changed even if the new value is the same as the current one
    */
    function _setMetaData(
        BaseModuleStorage storage $, string memory metadata_
    ) internal virtual  {
        $._metadata = metadata_;
        emit Metadata(metadata_, metadata_);
    }


    /** 
    * @dev the tokenId will be changed even if the new value is the same as the current one
    */
    function _setTokenId(
        BaseModuleStorage storage $, string memory tokenId_
    ) internal virtual  {
        $._tokenId = tokenId_;
        emit TokenId(tokenId_, tokenId_);
    }

    /** 
    * @dev The terms will be changed even if the new value is the same as the current one
    */
    function _setTerms(BaseModuleStorage storage $, IERC1643CMTAT.DocumentInfo memory terms_) internal virtual {
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
    function _setInformation(BaseModuleStorage storage $, string memory information_) internal virtual {
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
