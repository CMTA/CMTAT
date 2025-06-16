//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/* ==== Tokenization === */
import {IERC3643ERC20Enforcement} from "../../interfaces/tokenization/IERC3643Partial.sol";
import { IERC7551ERC20EnforcementTokenFrozenEvent, IERC7551ERC20EnforcementEvent} from "../../interfaces/tokenization/draft-IERC7551.sol";
/**
 * @title ERC20Enforcement module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20EnforcementModuleInternal is ERC20Upgradeable,IERC7551ERC20EnforcementEvent,  IERC7551ERC20EnforcementTokenFrozenEvent {
    error CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance();
    error CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance(); 
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20EnforcementModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20EnforcementModuleStorageLocation = 0x9d8059a24cb596f1948a937c2c163cf14465c2a24abfd3cd009eec4ac4c39800;

    /* ==== ERC-7201 State Variables === */
    struct ERC20EnforcementModuleStorage {
        mapping(address => uint256)  _frozenTokens;
    }
    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _getFrozenTokens(address account) internal view virtual returns (uint256) {
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        return $._frozenTokens[account];
     }

    function _getActiveBalanceOf(address account) internal view  returns (uint256){
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        return ERC20Upgradeable.balanceOf(account) - $._frozenTokens[account];
     }

     function _freezePartialTokens(address account, uint256 value, bytes memory data) internal virtual{
       ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        // Retrieve current value
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        uint256 frozenBalance = $._frozenTokens[account] + value;
        // Check
        require(balance >= frozenBalance, CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance());
        // Update frozenBalance
        $._frozenTokens[account] = frozenBalance;
        emit TokensFrozen(account, value, data);
    }

    function _unfreezePartialTokens(address account, uint256 value, bytes memory data) internal virtual{
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        require($._frozenTokens[account] >= value, CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance());
        // Update frozenBalance
        $._frozenTokens[account] = $._frozenTokens[account] - value;
        emit TokensUnfrozen(account, value, data);
    }

    /**
    * @dev unfreeze tokens during a forced transfer/burn
    */
    function _unfreezeTokens(address from, uint256 value, bytes memory data) internal virtual{
        uint256 balance = ERC20Upgradeable.balanceOf(from);
        if(value > balance){
            revert ERC20InsufficientBalance(_msgSender(), balance, value-balance);
        }
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        // Frozen token can not be < balance
        uint256 activeBalance = balance - $._frozenTokens[from];
        if (value > activeBalance) {
            uint256 tokensToUnfreeze = value - activeBalance;
            $._frozenTokens[from] = $._frozenTokens[from] - tokensToUnfreeze;
            emit TokensUnfrozen(from, tokensToUnfreeze, data);
        }
    }

    function _forcedTransfer(address from, address to, uint256 value, bytes memory data) internal virtual {
        _unfreezeTokens(from, value, data);
        if(to == address(0)){
            _burn(from, value);
        } else{
            // Spend allowance
            // See https://ethereum-magicians.org/t/erc-3643-the-t-rex-token-standard/6844/11
            uint256 currentAllowance = allowance(from, to);
            if (currentAllowance > 0 && currentAllowance < type(uint256).max) {
                if (currentAllowance < value) {
                     unchecked {
                        _approve(from, to, 0, false);
                     }
                } else{
                    unchecked {
                         _approve(from, to, currentAllowance - value, false);
                    }
                }
              
            }
            _transfer(from, to, value);
        }
        emit Enforcement(_msgSender(), from, value, data);
    }

    function _checkActiveBalance(address from, uint256 value) internal virtual view returns(bool){
         uint256 frozenTokensLocal = _getFrozenTokens(from);
        if(frozenTokensLocal > 0 ){
            uint256 activeBalance = balanceOf(from) - frozenTokensLocal;
            if(value > activeBalance) {
                   return false;
            }
        } 
        return true;

    }

    /* ============ ERC-7201 ============ */
    function _getEnforcementModuleStorage() private pure returns (ERC20EnforcementModuleStorage storage $) {
        assembly {
            $.slot := ERC20EnforcementModuleStorageLocation
        }
    }
}
