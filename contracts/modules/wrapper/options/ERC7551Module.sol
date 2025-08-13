//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ExtraInformationModule} from "../extensions/ExtraInformationModule.sol";
/* ==== Tokenization === */
import {IERC1643CMTAT, IERC1643} from "../../../interfaces/tokenization/draft-IERC1643CMTAT.sol";
import {IERC7551Document} from "../../../interfaces/tokenization/draft-IERC7551.sol";
abstract contract ERC7551Module is ExtraInformationModule, IERC7551Document {
    /* ============ Events ============ */
    /**
    * @notice Emitted when the metadata string is updated.
    * @param newMetaData The new metadata value (e.g. a URL or reference hash).
    */

    event MetaData(
        string newMetaData
    );
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC7551Module")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC7551ModuleStorageLocation = 0x2727314c926b592b6f70e7d6d2e4677ebcac070f293306927f71fe77858eec00;

    /* ==== ERC-7201 State Variables === */
    struct ERC7551ModuleStorage {
           string _metadata;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ State Restricted Functions ============ */

    /** 
    *   
    * @dev The metadata will be changed even if the new value is the same as the current one
    * @inheritdoc IERC7551Document
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    function setMetaData(
        string calldata metadata_
    ) public virtual override(IERC7551Document) onlyRole(EXTRA_INFORMATION_ROLE) {
        ERC7551ModuleStorage storage $ = _getERC7551ModuleStorage();
        _setMetaData($,  metadata_);
    }

    /**
    *  @inheritdoc IERC7551Document
    * @custom:access-control
    * - the caller must have the `EXTRA_INFORMATION_ROLE`.
    */
    function setTerms(bytes32 hash, string calldata uri) public virtual override(IERC7551Document) onlyRole(EXTRA_INFORMATION_ROLE) {
        IERC1643CMTAT.DocumentInfo memory terms_ = IERC1643CMTAT.DocumentInfo("", uri, hash);
        _setTerms(terms_);
    }

    /* ============ View functions ============ */
    function metaData() public view virtual override(IERC7551Document) returns (string memory metadata_) {
        ERC7551ModuleStorage storage $ = _getERC7551ModuleStorage();
        return $._metadata;
    }

    /**
    *  @inheritdoc IERC7551Document
    */
    function termsHash() public view virtual override(IERC7551Document) returns (bytes32 hash_){
        return terms().doc.documentHash;
    }
    
    /**
    *  As defined in ICMTATMandatory
    */
    function termsURI() public view returns (string memory) {
        return terms().doc.uri;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
   function _setMetaData(
        ERC7551ModuleStorage storage $, string memory metadata_
    ) internal virtual  {
        $._metadata = metadata_;
        emit MetaData(metadata_);
    }

    /* ============ ERC-7201 ============ */
    function _getERC7551ModuleStorage() private pure returns (ERC7551ModuleStorage storage $) {
        assembly {
            $.slot := ERC7551ModuleStorageLocation
        }
    }
}
