//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Openzeppelin === */
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
/* ==== Tokenization === */
import {IERC1643CMTAT, IERC1643} from "../../../interfaces/tokenization/draft-IERC1643CMTAT.sol";
import {ICMTATBase} from "../../../interfaces/tokenization/ICMTAT.sol";
abstract contract ExtraInformationModule is Initializable, ICMTATBase {
     bytes32 public constant EXTRA_INFORMATION_ROLE = keccak256("EXTRA_INFORMATION_ROLE");
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ExtraInformationModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ExtraInformationModuleStorageLocation = 0xd2d5d34c4a4dea00599692d3257c0aebc5e0359176118cd2364ab9b008c2d100;

    /* ==== ERC-7201 State Variables === */
    struct ExtraInformationModuleStorage {
            string _tokenId;
            Terms _terms;
            string _information;
    }

    /* ============ Modifier ============ */
    modifier onlyExtraInfoManager() {
        _authorizeExtraInfoManagement();
        _;
    }
    /* ============  Initializer Function ============ */
    /**
     * @dev Sets the values for {tokenId}, {terms_} and {information}.
     *
     */
    function __ExtraInformationModule_init_unchained(
        string memory tokenId_,
        IERC1643CMTAT.DocumentInfo memory terms_,
        string memory information_
    ) internal virtual onlyInitializing {
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

    /* ============  Restricted Functions ============ */
    
    /** 
    * @dev the tokenId will be changed even if the new value is the same as the current one
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    function setTokenId(
        string calldata tokenId_
    ) public virtual override(ICMTATBase) onlyExtraInfoManager {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setTokenId($, tokenId_);
    }

    /** 
    * @inheritdoc ICMTATBase
    * @dev The terms will be changed even if the new value is the same as the current one
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    function setTerms(IERC1643CMTAT.DocumentInfo calldata terms_) public virtual override(ICMTATBase) onlyExtraInfoManager{
		_setTerms(terms_);
    }

    /** 
    * @inheritdoc ICMTATBase
    * @dev The information will be changed even if the new value is the same as the current one
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    
    function setInformation(
        string calldata information_
    ) public virtual onlyExtraInfoManager {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setInformation($, information_);
    }

    /* ============ View functions ============ */
    /**
    * @inheritdoc ICMTATBase
    */
    function tokenId() public view  virtual override(ICMTATBase) returns (string memory tokenId_) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._tokenId;
    }

    /**
    * @inheritdoc ICMTATBase
    */
    function terms() public view virtual override(ICMTATBase)  returns (Terms memory terms_) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._terms;
    }
    
    /**
    * @inheritdoc ICMTATBase
    */
    function information() public view virtual override(ICMTATBase) returns (string memory information_) {
        ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        return $._information;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setTerms(IERC1643CMTAT.DocumentInfo memory terms_) internal{
		ExtraInformationModuleStorage storage $ = _getExtraInformationModuleStorage();
        _setTerms($, terms_);
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

    /* ============ Access Control ============ */
    function  _authorizeExtraInfoManagement() internal virtual{}

    /* ============ ERC-7201 ============ */
    function _getExtraInformationModuleStorage() private pure returns (ExtraInformationModuleStorage storage $) {
        assembly {
            $.slot := ExtraInformationModuleStorageLocation
        }
    }
}
