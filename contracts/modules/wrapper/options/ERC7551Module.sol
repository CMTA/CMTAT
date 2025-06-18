//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ExtraInformationModule} from "../extensions/ExtraInformationModule.sol";
/* ==== Tokenization === */
import {IERC1643CMTAT, IERC1643} from "../../../interfaces/tokenization/draft-IERC1643CMTAT.sol";
import {IERC7551Document} from "../../../interfaces/tokenization/draft-IERC7551.sol";
abstract contract ERC7551Module is ExtraInformationModule, IERC7551Document {
    /* ============ Events ============ */
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
    function metaData() public view virtual override(IERC7551Document) returns (string memory) {
        ERC7551ModuleStorage storage $ = _getERC7551ModuleStorage();
        return $._metadata;
    }

    /* ============  Restricted Functions ============ */

    /** 
    * 
    * @notice The metadata will be changed even if the new value is the same as the current one
    */
    function setMetaData(
        string calldata metadata_
    ) public override(IERC7551Document) onlyRole(EXTRA_INFORMATION_ROLE) {
        ERC7551ModuleStorage storage $ = _getERC7551ModuleStorage();
        _setMetaData($,  metadata_);
    }

        /**
    *  @notice MUST return the SHA-256 (or Keccak-256) hash of the “Terms” document.
    */
    function termsHash() public view virtual override returns (bytes32){
        return terms().doc.documentHash;
    }

    function setTerms(bytes32 hash, string calldata uri) onlyRole(EXTRA_INFORMATION_ROLE) public virtual override{
        IERC1643CMTAT.DocumentInfo memory terms = IERC1643CMTAT.DocumentInfo("", uri, hash);
        _setTerms(terms);
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
