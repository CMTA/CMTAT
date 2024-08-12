//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// required OZ imports here
import "../../security/AuthorizationModule.sol";
import "../../../libraries/Errors.sol";

abstract contract BaseModule is AuthorizationModule {
    /* ============ State Variables ============ */
    /** 
    * @notice 
    * Get the current version of the smart contract
    */
    string public constant VERSION = "2.5.0";
    
    /* ============ Events ============ */
    event Term(string indexed newTermIndexed, string newTerm);
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
            string _terms;
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
        string memory terms_,
        string memory information_
    ) internal onlyInitializing {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        $._tokenId = tokenId_;
        $._terms = terms_;
        $._information = information_;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function tokenId() public view virtual returns (string memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._tokenId;
    }

    function terms() public view virtual returns (string memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._terms;
    }
    function information() public view virtual returns (string memory) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        return $._information;
    }

    /** 
    * @notice the tokenId will be changed even if the new value is the same as the current one
    */
    function setTokenId(
        string calldata tokenId_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        $._tokenId = tokenId_;
        emit TokenId(tokenId_, tokenId_);
    }

    /** 
    * @notice The terms will be changed even if the new value is the same as the current one
    */
    function setTerms(
        string calldata terms_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        $._terms  = terms_;
        emit Term(terms_, terms_);
    }

    /** 
    * @notice The information will be changed even if the new value is the same as the current one
    */
    function setInformation(
        string calldata information_
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        BaseModuleStorage storage $ = _getBaseModuleStorage();
        $._information  = information_;
        emit Information(information_, information_);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ ERC-7201 ============ */
    function _getBaseModuleStorage() private pure returns (BaseModuleStorage storage $) {
        assembly {
            $.slot := BaseModuleStorageLocation
        }
    }

}
