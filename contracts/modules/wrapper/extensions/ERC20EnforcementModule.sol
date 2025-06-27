//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
/* ==== Module === */
import {ERC20EnforcementModuleInternal} from "../../internal/ERC20EnforcementModuleInternal.sol";
/* ==== Tokenization === */
import {IERC3643ERC20Enforcement} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551ERC20Enforcement, IERC7551ERC20EnforcementEvent} from "../../../interfaces/tokenization/draft-IERC7551.sol";
/**
 * @title ERC20Enforcement module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20EnforcementModule is ERC20EnforcementModuleInternal, AccessControlUpgradeable , IERC7551ERC20Enforcement, IERC3643ERC20Enforcement{
    /* ============ State Variables ============ */
    bytes32 public constant ERC20ENFORCER_ROLE = keccak256("ERC20ENFORCER_ROLE");

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

   /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    */
    function getFrozenTokens(address account) public override(IERC7551ERC20Enforcement, IERC3643ERC20Enforcement) view virtual returns (uint256) {
        return _getFrozenTokens(account);
     }

   /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    */
    function getActiveBalanceOf(address account) public view override(IERC7551ERC20Enforcement) returns (uint256){
        return _getActiveBalanceOf(account);
     }

    /* ============  ERC-20 Enforcement ============ */
    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function forcedTransfer(address from, address to, uint256 value, bytes calldata data) public virtual override(IERC7551ERC20Enforcement)  onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
       _forcedTransfer(from, to, value, data);
       return true;
    }

    /**
    *
    * @inheritdoc IERC3643ERC20Enforcement
    * @custom:access-control
    * - the caller must have the `DEFAULT_ADMIN_ROLE`.
    */
    function forcedTransfer(address from, address to, uint256 value) public virtual override(IERC3643ERC20Enforcement) onlyRole(DEFAULT_ADMIN_ROLE) returns (bool)  {
       _forcedTransfer(from, to, value, "");
       return true;
    }

    /**
    *
    * @inheritdoc IERC3643ERC20Enforcement
    * @custom:access-control
    * - the caller must have the `ERC20ENFORCER_ROLE`.
    */
    function freezePartialTokens(address account, uint256 value) public virtual override(IERC3643ERC20Enforcement) onlyRole(ERC20ENFORCER_ROLE){
        _freezePartialTokens(account, value, "");
    }

    /**
    *
    * @inheritdoc IERC3643ERC20Enforcement
    * @custom:access-control
    * - the caller must have the `ERC20ENFORCER_ROLE`.
    */
    function unfreezePartialTokens(address account, uint256 value) public virtual override(IERC3643ERC20Enforcement) onlyRole(ERC20ENFORCER_ROLE) {
        _unfreezePartialTokens(account, value, "");
    }

    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    * @custom:access-control
    * - the caller must have the `ERC20ENFORCER_ROLE`.
    */
    function freezePartialTokens(address account, uint256 value, bytes calldata data) public virtual override(IERC7551ERC20Enforcement) onlyRole(ERC20ENFORCER_ROLE){
        _freezePartialTokens(account, value, data);
    }

    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    * @custom:access-control
    * - the caller must have the `ERC20ENFORCER_ROLE`.
    */
    function unfreezePartialTokens(address account, uint256 value, bytes calldata data) public virtual override(IERC7551ERC20Enforcement) onlyRole(ERC20ENFORCER_ROLE) {
        _unfreezePartialTokens(account, value, data);
    }

}
