//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

/* ==== OpenZeppelin === */
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
/* ==== Module === */
import {AuthorizationModule} from "../../security/AuthorizationModule.sol";
/* ==== Technical === */
import {IBurnERC20} from "../../../interfaces/technical/IMintBurnToken.sol";
/* ==== Tokenization === */
import {IERC3643ERC20Enforcement} from "../../../interfaces/tokenization/IERC3643Partial.sol";
import {IERC7551ERC20Enforcement} from "../../../interfaces/tokenization/draft-IERC7551.sol";

/**
 * @title ERC20Enforcement module.
 * @dev 
 *
 * Contains all burn functions, inherits from ERC-20
 */
abstract contract ERC20EnforcementModule is ERC20Upgradeable, IERC7551ERC20Enforcement, IERC3643ERC20Enforcement, AuthorizationModule {
    error CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance();
    error CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance(); 

    string internal constant TEXT_TRANSFER_REJECTED_FROM_INSUFFICIENT_ACTIVE_BALANCE =
        "Address from:insufficient active balance";
   
    /* ============ State Variables ============ */
    bytes32 public constant ERC20ENFORCER_ROLE = keccak256("ERC20ENFORCER_ROLE");

    
    /* ============ Events ============ */
    /**
    * @notice Emitted when a transfer is forced.
    */
    event Enforcement (address indexed enforcer, address indexed account, uint256 amount, bytes data);
    
    /* ============ ERC-7201 ============ */
    // keccak256(abi.encode(uint256(keccak256("CMTAT.storage.ERC20EnforcementModule")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC20EnforcementModuleStorageLocation = 0xdbd8d607565c0370ae5f91651ca67fd26d4438022bf72037316600e29e6a3a00;

    /* ==== ERC-7201 State Variables === */
    struct ERC20EnforcementModuleStorage {
        mapping(address => uint256)  _frozenTokens;
    }

    /* ============  Initializer Function ============ */
    function __ERC20EnforcementModule_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    */
     function getFrozenTokens(address account) public override(IERC7551ERC20Enforcement, IERC3643ERC20Enforcement) view virtual returns (uint256) {
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        return $._frozenTokens[account];
     }

    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    */
     function getActiveBalanceOf(address account) public view override(IERC7551ERC20Enforcement) returns (uint256){
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        return ERC20Upgradeable.balanceOf(account) - $._frozenTokens[account];
     }

    /* ============  ERC-20 Enforcement ============ */
    /**
    *
    * @inheritdoc IERC7551ERC20Enforcement
    */
    function forcedTransfer(address from, address to, uint256 value, bytes calldata data) public virtual override(IERC7551ERC20Enforcement)  onlyRole(ERC20ENFORCER_ROLE) returns (bool) {
       _forcedTransfer(from, to, value, data);
       return true;
    }

    /**
    *
    * @inheritdoc IERC3643ERC20Enforcement
    */
    function forcedTransfer(address from, address to, uint256 value) public virtual override(IERC3643ERC20Enforcement) onlyRole(ERC20ENFORCER_ROLE) returns (bool)  {
       _forcedTransfer(from, to, value, "");
       return true;
    }
    /**
    *
    * @inheritdoc IERC3643ERC20Enforcement
    */
    function freezePartialTokens(address account, uint256 value) public virtual override(IERC7551ERC20Enforcement, IERC3643ERC20Enforcement) onlyRole(ERC20ENFORCER_ROLE){
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        // Retrieve current value
        uint256 balance = ERC20Upgradeable.balanceOf(account);
        uint256 frozenBalance = $._frozenTokens[account] + value;
        // Check
        require(balance >= frozenBalance, CMTAT_ERC20EnforcementModule_ValueExceedsAvailableBalance());
        // Update frozenBalance
        $._frozenTokens[account] = frozenBalance;
        emit TokensFrozen(account, value);
    }

    /**
    *
    * @inheritdoc IERC3643ERC20Enforcement
    */
    function unfreezePartialTokens(address account, uint256 value) public virtual override(IERC7551ERC20Enforcement, IERC3643ERC20Enforcement) onlyRole(ERC20ENFORCER_ROLE) {
        ERC20EnforcementModuleStorage storage $ = _getEnforcementModuleStorage();
        require($._frozenTokens[account] >= value, CMTAT_ERC20EnforcementModule_ValueExceedsFrozenBalance());
        // Update frozenBalance
        $._frozenTokens[account] = $._frozenTokens[account] - value;
        emit TokensUnfrozen(account, value);
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _unfreezeTokens(address from, uint256 value) internal{
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
            emit TokensUnfrozen(from, tokensToUnfreeze);
        }
    }
    function _forcedTransfer(address from, address to, uint256 value, bytes memory data) internal {
        _unfreezeTokens(from, value);
        // Spend allowance
        // See https://ethereum-magicians.org/t/erc-3643-the-t-rex-token-standard/6844/11
        uint256 currentAllowance = allowance(to, from);
        if (currentAllowance < type(uint256).max) {
            if (currentAllowance < value) {
               _approve(to, from, currentAllowance, false);
            }
            unchecked {
                _approve(to, from, currentAllowance - value, false);
            }
        }
        if(to == address(0)){
            _burn(from, value);
        } else {
            _transfer(from, to, value);
        }
        emit Enforcement(_msgSender(), from, value, data);
    }

    function _checkActiveBalance(address from, uint256 value) internal view returns(bool){
         uint256 frozenTokensLocal = getFrozenTokens(from);
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
