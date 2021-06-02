pragma solidity ^0.8.2;

// required OZ imports here
import "../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "./modules/BaseModule.sol";
import "./modules/AuthorizationModule.sol";
import "./modules/BurnModule.sol";
import "./modules/MintModule.sol";
import "./modules/BurnModule.sol";
import "./modules/EnforcementModule.sol";
import "./modules/PauseModule.sol";

contract CMTAT is Initializable, ContextUpgradeable, BaseModule, AuthorizationModule, PauseModule, MintModule, BurnModule, EnforcementModule {
  uint8 constant TRANSFER_OK = 0;
  string constant TEXT_TRANSFER_OK = "No restriction";

  function initialize (string memory name, string memory symbol) public initializer {
    __CMTAT_init(name, symbol);
  }

  /**
    * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
    * account that deploys the contract.
    *
    * See {ERC20-constructor}.
    */
  function __CMTAT_init(string memory name, string memory symbol) internal initializer {
    __Context_init_unchained();
    __Base_init_unchained(0);
    __AccessControl_init_unchained();
    __ERC20_init_unchained(name, symbol);
    __Pausable_init_unchained();
    __Enforcement_init_unchained();
    __CMTAT_init_unchained();
  }

  function __CMTAT_init_unchained() internal initializer {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(ENFORCER_ROLE, _msgSender());
    _setupRole(MINTER_ROLE, _msgSender());
    _setupRole(BURNER_ROLE, _msgSender());
    _setupRole(PAUSER_ROLE, _msgSender());
  }

  /**
    * @dev Creates `amount` new tokens for `to`.
    *
    * See {ERC20-_mint}.
    *
    * Requirements:
    *
    * - the caller must have the `MINTER_ROLE`.
    */
  function mint(address to, uint256 amount) public {
    require(hasRole(MINTER_ROLE, _msgSender()), "CMTAT: must have minter role to mint");
    _mint(to, amount);
    emit Mint(to, amount);
  }

  /**
    * @dev Destroys `amount` tokens from `account`, deducting from the caller's
    * allowance.
    *
    * See {ERC20-_burn} and {ERC20-allowance}.
    *
    * Requirements:
    *
    * - the caller must have allowance for ``accounts``'s tokens of at least
    * `amount`.
    */
  function burnFrom(address account, uint256 amount) public {
    require(hasRole(BURNER_ROLE, _msgSender()), "CMTAT: must have burner role to burn");
    uint256 currentAllowance = allowance(account, _msgSender());
    require(currentAllowance >= amount, "CMTAT: burn amount exceeds allowance");
    unchecked {
        _approve(account, _msgSender(), currentAllowance - amount);
    }
    _burn(account, amount);
    emit Burn(account, amount);
  }

  /**
    * @dev Pauses all token transfers.
    *
    * See {ERC20Pausable} and {Pausable-_pause}.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function pause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "CMTAT: must have pauser role to pause");
    _pause();
  }

  /**
    * @dev Unpauses all token transfers.
    *
    * See {ERC20Pausable} and {Pausable-_unpause}.
    *
    * Requirements:
    *
    * - the caller must have the `PAUSER_ROLE`.
    */
  function unpause() public {
    require(hasRole(PAUSER_ROLE, _msgSender()), "CMTAT: must have pauser role to unpause");
    _unpause();
  }

  /**
    * @dev Triggers a forced transfer.
    *
    */
  function enforceTransfer(address owner, address destination, uint amount, string memory reason) public {
    require(hasRole(ENFORCER_ROLE, _msgSender()), "CMTAT: must have enforcer role to enforce transfer");
    _enforceTransfer(owner, destination, amount, reason);
  }

  /**
    * @dev Freezes an address.
    *
    */
  function freeze(address account) public returns (bool) {
    require(hasRole(ENFORCER_ROLE, _msgSender()), "CMTAT: must have enforcer role to freeze");
    return _freeze(account);
  }

  /**
    * @dev Unfreezes an address.
    *
    */
  function unfreeze(address account) public returns (bool) {
    require(hasRole(ENFORCER_ROLE, _msgSender()), "CMTAT: must have enforcer role to unfreeze");
    return _unfreeze(account);
  }

  function decimals() public view virtual override(ERC20Upgradeable, BaseModule) returns (uint8) { 
    return super.decimals();
  }

  function transferFrom(address sender, address recipient, uint256 amount) public virtual override(ERC20Upgradeable, BaseModule) returns (bool) {
    return super.transferFrom(sender, recipient, amount);
  }

  /**
  * @dev ERC1404 check if _value token can be transferred from _from to _to
  * @param from address The address which you want to send tokens from
  * @return code of the rejection reason
  */
  function detectTransferRestriction (address from, address /* to */, uint256 /* value */) public view returns (uint8) {
    if (paused()) {
      return TRANSFER_REJECTED_PAUSED;
    }
    if (frozen(from)) {
      return TRANSFER_REJECTED_FROZEN;
    }
    return TRANSFER_OK;
  }

  /**
  * @dev ERC1404 returns the human readable explaination corresponding to the error code returned by detectTransferRestriction
  * @param restrictionCode The error code returned by detectTransferRestriction
  * @return The human readable explaination corresponding to the error code returned by detectTransferRestriction
  */
  function messageForTransferRestriction (uint8 restrictionCode) external pure returns (string memory) {
    if (restrictionCode == TRANSFER_OK) {
      return TEXT_TRANSFER_OK;
    } else if (restrictionCode == TRANSFER_REJECTED_PAUSED) {
      return TEXT_TRANSFER_REJECTED_PAUSED;
    } else if (restrictionCode == TRANSFER_REJECTED_FROZEN) {
      return TEXT_TRANSFER_REJECTED_FROZEN;
    }
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20Upgradeable) {
    super._beforeTokenTransfer(from, to, amount);

    require(!paused(), "CMTAT: token transfer while paused");
    require(!frozen(from), "CMTAT: token transfer while frozen");
  }

  uint256[50] private __gap;
}
