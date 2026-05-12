// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== Module === */
import {ERC20EnforcementModule} from "../extensions/ERC20EnforcementModule.sol";
/* ==== Tokenization === */
import {IERC7551ERC20Enforcement, IERC7551ERC20EnforcementEvent, IERC7551ERC20EnforcementTokenFrozenEvent} from "../../../interfaces/tokenization/draft-IERC7551.sol";

/**
 * @title ERC20EnforcementERC7551 module.
 * @dev
 *
 * Extends ERC20EnforcementModule with ERC-7551 specific functions:
 * - getActiveBalanceOf view function
 * - bytes data overloads for forcedTransfer, freezePartialTokens, unfreezePartialTokens
 */
abstract contract ERC20EnforcementERC7551Module is ERC20EnforcementModule, IERC7551ERC20Enforcement {

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @inheritdoc IERC7551ERC20Enforcement
     */
    function getFrozenTokens(address account)
    public view virtual override(ERC20EnforcementModule, IERC7551ERC20Enforcement)
    returns (uint256 frozenBalance_) {
        return ERC20EnforcementModule.getFrozenTokens(account);
    }

    /**
     * @inheritdoc IERC7551ERC20Enforcement
     */
    function getActiveBalanceOf(address account)
    public view virtual override(IERC7551ERC20Enforcement)
    returns (uint256 activeBalance_) {
        return _getActiveBalanceOf(account);
    }

    /**
     * @inheritdoc IERC7551ERC20Enforcement
     * @custom:access-control
     * - Protected by `onlyForcedTransferManager`.
     */
    function forcedTransfer(address from, address to, uint256 value, bytes calldata data)
    public virtual override(IERC7551ERC20Enforcement) onlyForcedTransferManager returns (bool) {
        uint256 frozenTokensBefore = _getFrozenTokens(from);
        _forcedTransfer(from, to, value);
        uint256 frozenTokensAfter = _getFrozenTokens(from);
        if (frozenTokensAfter < frozenTokensBefore) {
            emit IERC7551ERC20EnforcementTokenFrozenEvent.TokensUnfrozen(from, frozenTokensBefore - frozenTokensAfter, data);
        }
        emit IERC7551ERC20EnforcementEvent.ForcedTransfer(_msgSender(), from, to, value, data);
        return true;
    }

    /**
     * @inheritdoc IERC7551ERC20Enforcement
     * @custom:access-control
     * - Protected by `onlyERC20Enforcer`.
     */
    function freezePartialTokens(address account, uint256 value, bytes calldata data)
    public virtual override(IERC7551ERC20Enforcement) onlyERC20Enforcer {
        _freezePartialTokens(account, value);
        emit IERC7551ERC20EnforcementTokenFrozenEvent.TokensFrozen(account, value, data);
    }

    /**
     * @inheritdoc IERC7551ERC20Enforcement
     * @custom:access-control
     * - Protected by `onlyERC20Enforcer`.
     */
    function unfreezePartialTokens(address account, uint256 value, bytes calldata data)
    public virtual override(IERC7551ERC20Enforcement) onlyERC20Enforcer {
        _unfreezePartialTokens(account, value);
        emit IERC7551ERC20EnforcementTokenFrozenEvent.TokensUnfrozen(account, value, data);
    }
}
