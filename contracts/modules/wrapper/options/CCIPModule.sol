//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC2771ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";

import {IGetCCIPAdmin} from "../../../interfaces/technical/IGetCCIPAdmin.sol";
/**
 * @title Chainlink CCIP specific functions
 * @dev 
 *
 * Implement CCIP specific functions to make CMTAT compatible with Chainlink CCIP (CCT standard)
 * 
 */
abstract contract CCIPModule is IGetCCIPAdmin {
    /* ============ Error ============ */
    error CMTAT_CCIPModule_SameValue();
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.CCIPModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CCIPModuleStorageLocation = 0x364fbfd89c0eee55bbc8dd10b1a9bf3e04fba9f3ee606f4c79a82f9941ad7a00;
 
    /* ==== ERC-7201 State Variables === */
    struct CCIPModuleStorage {
        /** 
        * @dev the CCIPAdmin can be used to register with the CCIP token admin registry, but has no other special powers,
        * and can only be transferred by calling setCCIPAdmin.
        */
        address  s_ccipAdmin;
    }

    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to the function setCCIPAdmin
    modifier onlyCCIPSetAdmin() {
        _authorizeCCIPSetAdmin();
        _;
    }

  /**
  * @notice Transfers the CCIPAdmin role to a new address
  * @dev only the owner can call this function, NOT the current ccipAdmin, and 1-step ownership transfer is used.
  * @param newAdmin The address to transfer the CCIPAdmin role to. Setting to address(0) is a valid way to revoke
  * the role
  */ 
  function setCCIPAdmin(address newAdmin) public onlyCCIPSetAdmin{
    CCIPModuleStorage storage $ = _getCCIPModuleStorage();
    address currentAdmin = $.s_ccipAdmin;
    require(newAdmin != currentAdmin, CMTAT_CCIPModule_SameValue());

    $.s_ccipAdmin = newAdmin;

    emit CCIPAdminTransferred(currentAdmin, newAdmin);
  }

  /**
  * Returns the current CCIPAdmin
  */
  function getCCIPAdmin() external view returns (address) {
    CCIPModuleStorage storage $ = _getCCIPModuleStorage();
    return $.s_ccipAdmin;
  }

function _authorizeCCIPSetAdmin() internal virtual;

/* ============ ERC-7201 ============ */
    function _getCCIPModuleStorage() internal pure returns (CCIPModuleStorage storage $) {
        assembly {
            $.slot := CCIPModuleStorageLocation
        }
    }
}