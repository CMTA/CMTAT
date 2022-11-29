//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "./modules/BaseModule.sol";
import "./modules/wrapper/AuthorizationModule.sol";
import "./modules/wrapper/BurnModule.sol";
import "./modules/wrapper/MintModule.sol";
import "./modules/wrapper/BurnModule.sol";
import "./modules/wrapper/EnforcementModule.sol";
import "./modules/wrapper/PauseModule.sol";
import "./modules/wrapper/ValidationModule.sol";
import "./modules/wrapper/MetaTxModule.sol";
import "./modules/wrapper/SnapshotModule.sol";
import "./modules/security/OnlyDelegateCallModule.sol";
import "./interfaces/IRuleEngine.sol";

contract CMTAT is
    Initializable,
    ContextUpgradeable,
    BaseModule,
    PauseModule,
    MintModule,
    BurnModule,
    EnforcementModule,
    ValidationModule,
    MetaTxModule,
    SnasphotModule,
    OnlyDelegateCallModule
{
     bool public deployedWithProxy;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address forwarder, bool deployedWithProxy_, address owner, string memory name, string memory symbol, string memory tokenId, string memory terms
    ) MetaTxModule(forwarder) {
         if(!deployedWithProxy_){
            // Initialize the contract to avoid front-running
            // Warning : do not initialize the proxy
            initialize(deployedWithProxy_, owner, name, symbol,tokenId, terms);
         }else{
            // Initialize the variable for the implementation
            deployedWithProxy = true;
            // Disable the possibility to initialize the implementation
            _disableInitializers();
         }   
    }

    function initialize(
        bool deployedWithProxy_,
        address owner,
        string memory name,
        string memory symbol,
        string memory tokenId,
        string memory terms
    ) public initializer {
        __CMTAT_init(deployedWithProxy_, owner, name, symbol, tokenId, terms);
    }

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    function __CMTAT_init(
        bool deployedWithProxy_,
        address owner,
        string memory name,
        string memory symbol,
        string memory tokenId,
        string memory terms
    ) internal onlyInitializing {
        // OpenZeppelin library
        // We call OZ init functions firstly 
        // because other modules inherit from these libraries
        __Context_init_unchained();
        __ERC20_init_unchained(name, symbol);
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        __Pausable_init_unchained();

        // Internal Modules
        __Enforcement_init_unchained();
        __Snapshot_init_unchained();
        
        // Other modules
        __Base_init_unchained(0, tokenId, terms);

        // CMTAT
        __CMTAT_init_unchained(deployedWithProxy_, owner);
    }


    function __CMTAT_init_unchained(bool deployedWithProxy_, address owner) internal onlyInitializing {
        deployedWithProxy = deployedWithProxy_;
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(ENFORCER_ROLE, owner);
        _grantRole(MINTER_ROLE, owner);
        _grantRole(BURNER_ROLE, owner);
        _grantRole(PAUSER_ROLE, owner);
        _grantRole(SNAPSHOOTER_ROLE, owner);
    }

    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, BaseModule)
        returns (uint8)
    {
        return BaseModule.decimals();
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override(ERC20Upgradeable, BaseModule) returns (bool) {
        return BaseModule.transferFrom(sender, recipient, amount);
    }

    /// @custom:oz-upgrades-unsafe-allow selfdestruct
    function kill() public onlyRole(DEFAULT_ADMIN_ROLE) onlyDelegateCall(deployedWithProxy) {
        selfdestruct(payable(_msgSender()));
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(SnapshotModuleInternal, ERC20Upgradeable) {
        require(!paused(), "CMTAT: token transfer while paused");
        require(!frozen(from), "CMTAT: token transfer while frozen");

        SnapshotModuleInternal._beforeTokenTransfer(from, to, amount);

        require(validateTransfer(from, to, amount), "CMTAT: transfer rejected by validation module");
    }

    /** 
    @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgSender()
        internal
        view
        override(MetaTxModule, ContextUpgradeable)
        returns (address sender)
    {
        return MetaTxModule._msgSender();
    }

    /** 
    @dev This surcharge is not necessary if you do not use the MetaTxModule
    */
    function _msgData()
        internal
        view
        override(MetaTxModule, ContextUpgradeable)
        returns (bytes calldata)
    {
        return MetaTxModule._msgData();
    }

    uint256[50] private __gap;
}
