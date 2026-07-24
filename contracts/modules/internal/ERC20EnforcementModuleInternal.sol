// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Tokenization === */
import {IERC7943FungibleEnforcementEventAndError} from "../../interfaces/tokenization/draft-IERC7943.sol";

/**
 * @title ERC20Enforcement module internal.
 * @dev 
 *
 * Contains specific ERC-20 enforcement actions
 */
abstract contract ERC20EnforcementModuleInternal is ERC20Upgradeable, IERC7943FungibleEnforcementEventAndError {
    // no argument to reduce contract code size
    error CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();
    error CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance();
    error CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance(); 
    error CMTAT_ERC20EnforcementModule_ValueEqualCurrentFrozenTokens();
    error CMTAT_ERC20EnforcementModule_SelfTransferNotAllowed();
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20EnforcementModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20EnforcementModuleStorageLocation = 0x9d8059a24cb596f1948a937c2c163cf14465c2a24abfd3cd009eec4ac4c39800;

    /* ==== ERC-7201 State Variables === */
    struct ERC20EnforcementModuleStorage {
        mapping(address account => uint256 frozenTokens)  _frozenTokens;
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _setFrozenTokens(address account, uint256 value) internal virtual returns(bool) {
        // The zero address holds no balance, so a non-zero frozen amount on it would make
        // _checkActiveBalance(address(0), value) fail for every value > 0 and revert the common
        // mint path (mint, batchMint, crosschainMint, the mint leg of burnAndMint).
        // Same guard as _freezePartialTokens / _unfreezePartialTokens.
        if (account == address(0)) {
            revert CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();
        }
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        uint256 frozenTokensLocal = $._frozenTokens[account];
        // Unfreeze path
        if(value < frozenTokensLocal) {
             uint256 difference = frozenTokensLocal - value;
             $ ._frozenTokens[account] =  value ;
             _unfreezeTokensEmitEvents(account,difference,  value);
        } else if(value > frozenTokensLocal) {
            // No underflow possible due to previous check
            uint256 difference = value - frozenTokensLocal;
            $._frozenTokens[account] = value;
            _freezeTokensEmitEvents(account, difference, value);
        } else { // Less probable path at the end
            revert CMTAT_ERC20EnforcementModule_ValueEqualCurrentFrozenTokens();
        }
        return true;
    }

    function _freezePartialTokens(address account, uint256 value) internal virtual{
       if (account == address(0)) {
            revert CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();
        }
       ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        // Retrieve current value
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        uint256 frozenTokensLocal = $._frozenTokens[account] + value;
        // Check
        require(balance >= frozenTokensLocal, CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance());
        // Update frozenTokens
        $._frozenTokens[account] = frozenTokensLocal;
        _freezeTokensEmitEvents(account, value, frozenTokensLocal);
    }

    function _unfreezePartialTokens(address account, uint256 value) internal virtual{
        if (account == address(0)) {
            revert CMTAT_ERC20EnforcementModule_ZeroAddressNotAllowed();
        }
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        require($._frozenTokens[account] >= value, CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance());
        // Update frozenBalance
        uint256 frozenTokensLocal  = $._frozenTokens[account] - value;
        $._frozenTokens[account] = frozenTokensLocal ;
        _unfreezeTokensEmitEvents(account, value,  frozenTokensLocal);
    }

    /**
    * @dev unfreeze tokens during a forced transfer/burn
    */
    function _unfreezeTokens(address account, uint256 value) internal virtual{
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        if(value > balance){
           revert CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance();
        } 
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        uint256 frozenTokensLocal = $._frozenTokens[account];
        // default value is 0 for uninitialized variable
        uint256 activeBalance;
        // Frozen amounts can be > balance through setFrozenTokens.
        if (frozenTokensLocal < balance) {
            activeBalance = balance - frozenTokensLocal;
        }
        if (value > activeBalance) {
            uint256 tokensToUnfreeze = value - activeBalance;
            frozenTokensLocal =  frozenTokensLocal - tokensToUnfreeze;
            $._frozenTokens[account] = frozenTokensLocal;
            _unfreezeTokensEmitEvents(account, tokensToUnfreeze,  frozenTokensLocal);
        }
    }

    function _forcedTransfer(address from, address to, uint256 value) internal virtual {
        // A self forced transfer moves no token, but _unfreezeTokens would still release the frozen ones
        require(from != to, CMTAT_ERC20EnforcementModule_SelfTransferNotAllowed());
        _unfreezeTokens(from, value);
        if(to == address(0)){
            ERC20Upgradeable._burn(from, value);
        } else{
            // Spend allowance
            // See https://ethereum-magicians.org/t/erc-3643-the-t-rex-token-standard/6844/11
            uint256 currentAllowance = allowance(from, to);
            if (currentAllowance > 0 && currentAllowance < type(uint256).max) {
                if (currentAllowance < value) {
                     unchecked {
                        ERC20Upgradeable._approve(from, to, 0, false);
                     }
                } else{
                    unchecked {
                         ERC20Upgradeable._approve(from, to, currentAllowance - value, false);
                    }
                }
              
            }
            ERC20Upgradeable._transfer(from, to, value);
        }
        emit ForcedTransfer(from, to, value);
    }

    function _freezeTokensEmitEvents(address account, uint256 /* difference */, uint256 frozenTokens) internal virtual {
        emit IERC7943FungibleEnforcementEventAndError.Frozen(account, frozenTokens);
    }

    function _unfreezeTokensEmitEvents(address account, uint256 /* difference */, uint256 frozenTokens) internal virtual {
        emit IERC7943FungibleEnforcementEventAndError.Frozen(account, frozenTokens );
    }

    /* ============ View functions ============ */
    function _checkActiveBalanceAndRevert(address from, uint256 value) internal virtual view {
        bool isValid;
        uint256 activeBalance;
        (isValid, activeBalance) = _checkActiveBalance(from, value);
        require(isValid, ERC7943InsufficientUnfrozenBalance(from, value,  activeBalance) );
    }

    /**
    * @dev we only check the balance if frozenTokens > 0
    * @return isValid True if `from` has enough unfrozen balance to move `value`.
    * @return activeBalance The unfrozen (active) balance available for `from`.
    */
    function _checkActiveBalance(address from, uint256 value) internal virtual view returns(bool isValid, uint256 activeBalance){
        uint256 frozenTokensLocal = _getFrozenTokens(from);
        if(frozenTokensLocal > 0 ){
            uint256 balance = ERC20Upgradeable.balanceOf(from);
            // Frozen amounts can be > balance through setFrozenTokens.
            if (frozenTokensLocal >= balance) {
                if (value == 0) {
                    return (true, 0);
                }
                return (false, 0);
            }
            activeBalance = balance - frozenTokensLocal;
            if(value > activeBalance) {
                   return (false, activeBalance);
            }
        } 
        // We don't check the balance if frozenTokens == 0
        // In case of insufficient balance for write call, the transaction (transfer, burn) will revert with an ERC-6093 custom errors
        return (true, activeBalance);
    }

    function _getFrozenTokens(address account) internal view virtual returns (uint256) {
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        return $._frozenTokens[account];
     }

    function _getActiveBalanceOf(address account) internal view  returns (uint256){
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        uint256 frozenTokens = $._frozenTokens[account];
        // Frozen amounts can be > balance through setFrozenTokens.
        if (frozenTokens >= balance) {
            return 0;
        }
        return balance - frozenTokens;
     }

    /* ============ ERC-7201 ============ */
    function _getEnforcementModuleStorage() private pure returns (ERC20EnforcementModuleStorage storage $) {
        assembly {
            $.slot := ERC20EnforcementModuleStorageLocation
        }
    }
}
