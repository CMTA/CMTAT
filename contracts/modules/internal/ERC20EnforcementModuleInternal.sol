// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Tokenization === */
import {IERC7551ERC20EnforcementTokenFrozenEvent, IERC7551ERC20EnforcementEvent} from "../../interfaces/tokenization/draft-IERC7551.sol";
import {IERC7943FungibleEnforcementEvent} from "../../interfaces/tokenization/draft-IERC7943.sol";
/**
 * @title ERC20Enforcement module internal.
 * @dev 
 *
 * Contains specific ERC-20 enforcement actions
 */
abstract contract ERC20EnforcementModuleInternal is ERC20Upgradeable,IERC7551ERC20EnforcementEvent,  IERC7551ERC20EnforcementTokenFrozenEvent, IERC7943FungibleEnforcementEvent {
    // no argument to reduce contract code size
    error CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance();
    error CMTAT_ERC20EnforcementModule_ValueExceedsActiveBalance();
    error CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance(); 
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
     function _freezePartialTokens(address account, uint256 value, bytes memory data) internal virtual{
       ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        // Retrieve current value
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        uint256 frozenTokensLocal = $._frozenTokens[account] + value;
        // Check
        require(balance >= frozenTokensLocal, CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance());
        // Update frozenTokens
        $._frozenTokens[account] = frozenTokensLocal;
        emit TokensFrozen(account, value, data);
        emit Frozen(account, frozenTokensLocal);
    }

    function _unfreezePartialTokens(address account, uint256 value, bytes memory data) internal virtual{
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        require($._frozenTokens[account] >= value, CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance());
        // Update frozenBalance
        uint256 frozenTokensLocal  = $._frozenTokens[account] - value;
        $._frozenTokens[account] = frozenTokensLocal ;
        emit TokensUnfrozen(account, value, data);
        emit Frozen(account, frozenTokensLocal );
    }

    /**
    * @dev unfreeze tokens during a forced transfer/burn
    */
    function _unfreezeTokens(address from, uint256 value, bytes memory data) internal virtual{
        uint256 balance = ERC20Upgradeable.balanceOf(from);
        if(value > balance){
           revert CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance();
        } 
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        // Frozen tokens can not be > balance
        uint256 activeBalance = balance - $._frozenTokens[from];
        if (value > activeBalance) {
            uint256 tokensToUnfreeze = value - activeBalance;
            uint256 frozenTokensLocal =  $._frozenTokens[from] - tokensToUnfreeze;
            $._frozenTokens[from] = frozenTokensLocal;
            emit TokensUnfrozen(from, tokensToUnfreeze, data);
            emit Frozen(from, frozenTokensLocal);
        }
    }

    function _forcedTransfer(address from, address to, uint256 value, bytes memory data) internal virtual {
        _unfreezeTokens(from, value, data);
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
        emit Enforcement(_msgSender(), from, value, data);
        emit ForcedTransfer(from, to, value);
    }

    /* ============ View functions ============ */
    function _checkActiveBalanceAndRevert(address from, uint256 value) internal virtual view {
        require(_checkActiveBalance(from, value),  CMTAT_ERC20EnforcementModule_ValueExceedsActiveBalance() );
    }

    function _checkActiveBalance(address from, uint256 value) internal virtual view returns(bool){
        uint256 frozenTokensLocal = _getFrozenTokens(from);
        if(frozenTokensLocal > 0 ){
            // Frozen amounts can not be > balance
            uint256 activeBalance = ERC20Upgradeable.balanceOf(from) - frozenTokensLocal;
            if(value > activeBalance) {
                   return false;
            }
        } 
        // We don't check the balance if frozenTokens == 0
        // In case of insufficient balance for write call, the transaction (transfer, burn) will revert with an ERC-6093 custom errors
        return true;
    }

    function _getFrozenTokens(address account) internal view virtual returns (uint256) {
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        return $._frozenTokens[account];
     }

    function _getActiveBalanceOf(address account) internal view  returns (uint256){
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        return ERC20Upgradeable.balanceOf(account) - $._frozenTokens[account];
     }

    /* ============ ERC-7201 ============ */
    function _getEnforcementModuleStorage() private pure returns (ERC20EnforcementModuleStorage storage $) {
        assembly {
            $.slot := ERC20EnforcementModuleStorageLocation
        }
    }
}
