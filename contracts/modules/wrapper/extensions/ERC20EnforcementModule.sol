// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ERC20EnforcementModuleInternal} from "../../internal/ERC20EnforcementModuleInternal.sol";
/* ==== Tokenization === */
import {IERC3643ERC20Enforcement, IERC7943FungibleEnforcement} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7943FungibleEnforcementSpecific} from "../../../interfaces/tokenization/draft-IERC7943.sol";

/**
 * @title ERC20Enforcement module.
 * @dev
 *
 * ERC-20 Enforcement related functions (freeze tokens, forced transfer).
 * Implements ERC-3643 and ERC-7943 enforcement interfaces.
 * For ERC-7551 enforcement (bytes data overloads), see ERC20EnforcementERC7551Module.
 */
abstract contract ERC20EnforcementModule is ERC20EnforcementModuleInternal, IERC3643ERC20Enforcement, IERC7943FungibleEnforcementSpecific {
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
     * @inheritdoc IERC7943FungibleEnforcement
     */
    function getFrozenTokens(address account) public view virtual override(IERC7943FungibleEnforcement) returns (uint256 frozenBalance_) {
        return _getFrozenTokens(account);
    }

    /* ============  ERC-20 Enforcement ============ */
    /**
     * @inheritdoc IERC7943FungibleEnforcement
     * @custom:access-control
     * - Protected by `onlyForcedTransferManager`.
     */
    function forcedTransfer(address from, address to, uint256 value)
    public virtual override(IERC7943FungibleEnforcement) onlyForcedTransferManager returns (bool) {
        _forcedTransfer(from, to, value, "");
        return true;
    }

    /**
     * @inheritdoc IERC3643ERC20Enforcement
     * @custom:access-control
     * - Protected by `onlyERC20Enforcer`.
     */
    function freezePartialTokens(address account, uint256 value)
    public virtual override(IERC3643ERC20Enforcement) onlyERC20Enforcer {
        _freezePartialTokens(account, value, "");
    }

    /**
     * @inheritdoc IERC3643ERC20Enforcement
     * @custom:access-control
     * - Protected by `onlyERC20Enforcer`.
     */
    function unfreezePartialTokens(address account, uint256 value)
    public virtual override(IERC3643ERC20Enforcement) onlyERC20Enforcer {
        _unfreezePartialTokens(account, value, "");
    }

    /**
     * @inheritdoc IERC7943FungibleEnforcementSpecific
     * @custom:access-control
     * - Protected by `onlyERC20Enforcer`.
     */
    function setFrozenTokens(address account, uint256 value)
    public virtual override(IERC7943FungibleEnforcementSpecific) onlyERC20Enforcer
    returns (bool result) {
        return _setFrozenTokens(account, value);
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /* ============ Access Control ============ */
    function _authorizeERC20Enforcer() internal virtual;
    function _authorizeForcedTransfer() internal virtual;
}
