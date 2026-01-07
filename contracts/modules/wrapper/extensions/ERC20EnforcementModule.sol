// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ERC20EnforcementModuleInternal} from "../../internal/ERC20EnforcementModuleInternal.sol";
/* ==== Tokenization === */
import {IERC3643ERC20Enforcement, IERC7943ERC20Enforcement} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551ERC20Enforcement, IERC7551ERC20EnforcementEvent} from "../../../interfaces/tokenization/draft-IERC7551.sol";
import {IERC7943ERC20EnforcementSpecific} from "../../../interfaces/tokenization/draft-IERC7943.sol";
/**
 * @title ERC20Enforcement module.
 * @dev 
 *
 * ERC-20 Enforcement related functions (freeze tokens, forced transfer)
 */
abstract contract ERC20EnforcementModule is ERC20EnforcementModuleInternal, IERC7551ERC20Enforcement, IERC3643ERC20Enforcement, IERC7943ERC20EnforcementSpecific{
    /* ============ State Variables ============ */
    bytes32 public constant ERC20ENFORCER_ROLE = keccak256("ERC20ENFORCER_ROLE");

    /* ============ Modifier ============ */
    /// @dev Modifier to restrict access to specific enforcer functions
    modifier onlyERC20Enforcer() {
        _authorizeERC20Enforcer();
        _;
    }

    /// @dev Modifier to restrict access to forced transfer functions
    modifier onlyForcedTransferManager() {
        _authorizeForcedTransfer();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

   /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    */
    function getFrozenTokens(address account) public override(IERC7551ERC20Enforcement, IERC7943ERC20Enforcement) view virtual returns (uint256 frozenBalance_) {
        return _getFrozenTokens(account);
     }

   /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    */
    function getActiveBalanceOf(address account) public view override(IERC7551ERC20Enforcement) returns (uint256 activeBalance_){
        return _getActiveBalanceOf(account);
     }

    /* ============  ERC-20 Enforcement ============ */
    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    * @custom:access-control
    * - Protected by `onlyForcedTransferManager`.
    */
    function forcedTransfer(address from, address to, uint256 value, bytes calldata data) 
    public virtual override(IERC7551ERC20Enforcement)  onlyForcedTransferManager returns (bool) {
       _forcedTransfer(from, to, value, data);
       return true;
    }

    /**
    *
    * @inheritdoc IERC7943ERC20Enforcement
    * @custom:access-control
    * - Protected by `onlyForcedTransferManager`.
    */
    function forcedTransfer(address from, address to, uint256 value) 
    public virtual override(IERC7943ERC20Enforcement) onlyForcedTransferManager returns (bool)  {
       _forcedTransfer(from, to, value, "");
       return true;
    }

    /**
    *
    * @inheritdoc IERC3643ERC20Enforcement
    * @custom:access-control
    * - Protected by `onlyERC20Enforcer`.
    */
    function freezePartialTokens(address account, uint256 value) 
    public virtual override(IERC3643ERC20Enforcement) onlyERC20Enforcer{
        _freezePartialTokens(account, value, "");
    }

    /**
    *
    * @inheritdoc IERC3643ERC20Enforcement
    * @custom:access-control
    * - Protected by `onlyERC20Enforcer`.
    */
    function unfreezePartialTokens(address account, uint256 value) 
    public virtual override(IERC3643ERC20Enforcement) onlyERC20Enforcer {
        _unfreezePartialTokens(account, value, "");
    }

    /**
    *
    * @inheritdoc IERC7943ERC20EnforcementSpecific
    * @custom:access-control
    * - Protected by `onlyERC20Enforcer `.
    */
    function setFrozenTokens(address account, uint256 value) 
    public virtual override(IERC7943ERC20EnforcementSpecific) onlyERC20Enforcer 
    returns(bool result) {
         return _setFrozenTokens(account, value);
    }

    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    * @custom:access-control
    * - Protected by `onlyERC20Enforcer`.
    */
    function freezePartialTokens(address account, uint256 value, bytes calldata data) 
    public virtual override(IERC7551ERC20Enforcement) onlyERC20Enforcer {
        _freezePartialTokens(account, value, data);
    }

    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    * @custom:access-control
    * - Protected by `onlyERC20Enforcer`.
    */
    function unfreezePartialTokens(address account, uint256 value, bytes calldata data) 
    public virtual override(IERC7551ERC20Enforcement) onlyERC20Enforcer {
        _unfreezePartialTokens(account, value, data);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ Access Control ============ */
    function _authorizeERC20Enforcer() internal virtual;
    function _authorizeForcedTransfer() internal virtual;

}
