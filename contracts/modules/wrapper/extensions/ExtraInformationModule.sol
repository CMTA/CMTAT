//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Tokenization === */
import {IERC1643CMTAT, IERC1643} from "../../../interfaces/tokenization/draft-IERC1643CMTAT.sol";
import {ICMTATBase} from "../../../interfaces/tokenization/ICMTAT.sol";
import {IERC7551Base} from "../../../interfaces/tokenization/draft-IERC7551.sol";
abstract contract ExtraInformationModule is IERC7551Base, ICMTATBase, AuthorizationModule {
    /* ============ Events ============ */
    event Information(
        string newInformation
    );
    event MetaData(
        string newMetaData
    );
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ExtraInformationModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ExtraInformationModuleStorageLocation = 0xd2d5d34c4a4dea00599692d3257c0aebc5e0359176118cd2364ab9b008c2d100;

    /* ==== ERC-7201 State Variables === */
    struct ExtraInformationModuleStorage {
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
    function __ExtraInformationModule_init_unchained(
        string memory tokenId_,
        IERC1643CMTAT.DocumentInfo memory terms_,
        string memory information_
    ) internal onlyInitializing {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
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
    * @inheritdoc ICMTATBase
    */
    function tokenId() public view  virtual override(ICMTATBase) returns (string memory) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._tokenId;
    }

    /**
    * @inheritdoc ICMTATBase
    */
    function terms() public view virtual override(ICMTATBase)  returns (Terms memory) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._terms;
    }
    
    /**
    * @inheritdoc ICMTATBase
    */
    function information() public view virtual override(ICMTATBase) returns (string memory) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._information;
    }

    /**
    * @inheritdoc IERC7551Base
    */
    function metaData() public view virtual override(IERC7551Base) returns (string memory) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._metadata;
    }


    /* ============  Restricted Functions ============ */
    
    /** 
    * @notice the tokenId will be changed even if the new value is the same as the current one
    */
    function setTokenId(
        string calldata tokenId_
    ) public virtual override(ICMTATBase)  onlyRole(DEFAULT_ADMIN_ROLE) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setTokenId($, tokenId_);
    }

    /** 
    * @inheritdoc ICMTATBase
    * @dev The terms will be changed even if the new value is the same as the current one
    */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) public virtual override(ICMTATBase) onlyRole(DEFAULT_ADMIN_ROLE) {
		ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setTerms($, terms_);
    }


    /** 
    * @inheritdoc ICMTATBase
    * @dev The information will be changed even if the new value is the same as the current one
    */
    function setInformation(
        string calldata information_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setInformation($, information_);
    }



    /** 
    * @inheritdoc IERC7551Base
    * @notice The metadata will be changed even if the new value is the same as the current one
    */
    function setMetaData(
        string calldata metadata_
    ) public override(IERC7551Base) onlyRole(DEFAULT_ADMIN_ROLE) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setMetaData($,  metadata_);
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setMetaData(
        ExtraInformationModuleStorage storage $, string memory metadata_
    ) internal virtual  {
        $._metadata = metadata_;
        emit MetaData(metadata_);
    }

    function _setTokenId(
        ExtraInformationModuleStorage storage $, string memory tokenId_
    ) internal virtual  {
        $._tokenId = tokenId_;
        emit TokenId(tokenId_, tokenId_);
    }

    function _setTerms(ExtraInformationModuleStorage storage $, IERC1643CMTAT.DocumentInfo memory terms_) internal virtual {
		// Terms/Document name
        $._terms.name = terms_.name;
        // Document
        $._terms.doc.documentHash  = terms_.documentHash;
        $._terms.doc.uri = terms_.uri;
        $._terms.doc.lastModified = block.timestamp;
		// Event
        emit Term($._terms);
    }

    function _setInformation(ExtraInformationModuleStorage storage $, string memory information_) internal virtual {
        $._information  = information_;
        emit Information(information_);
    }

    /* ============ ERC-7201 ============ */
    function _getExtraInformationModuleStorage() private pure returns (ExtraInformationModuleStorage storage $) {
        assembly {
            $.slot := ExtraInformationModuleStorageLocation
        }
    }
}
