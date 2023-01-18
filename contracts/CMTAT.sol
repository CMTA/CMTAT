//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "./modules/wrapper/mandatory/BaseModule.sol";
import "./modules/wrapper/mandatory/BurnModule.sol";
import "./modules/wrapper/mandatory/MintModule.sol";
import "./modules/wrapper/mandatory/EnforcementModule.sol";
import "./modules/wrapper/mandatory/ERC20BaseModule.sol";
import "./modules/wrapper/mandatory/SnapshotModule.sol";
import "./modules/wrapper/mandatory/PauseModule.sol";
import "./modules/wrapper/optional/ValidationModule.sol";
import "./modules/wrapper/optional/MetaTxModule.sol";
import "./modules/wrapper/optional/DebtModule.sol";
import "./modules/security/AuthorizationModule.sol";
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
    SnapshotModule,
    ERC20BaseModule,
    DebtModule
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address forwarder, bool deployedWithProxyIrrevocable_, address admin, 
    string memory nameIrrevocable, string memory symbolIrrevocable, string memory tokenId, 
    string memory terms,
    IRuleEngine ruleEngine,
    string memory information, 
    uint256 flag)
     MetaTxModule(forwarder) {
         if(!deployedWithProxyIrrevocable_){
            // Initialize the contract to avoid front-running
            // Warning : do not initialize the proxy
            initialize(deployedWithProxyIrrevocable_, admin, nameIrrevocable, symbolIrrevocable,tokenId, terms, ruleEngine, information, flag);
         }else{
            // Initialize the variable for the implementation
            deployedWithProxy = true;
            // Disable the possibility to initialize the implementation
            _disableInitializers();
         }   
    }

    function initialize(
        bool deployedWithProxyIrrevocable_,
        address admin,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        string memory tokenId,
        string memory terms,
        IRuleEngine ruleEngine,
        string memory information,
        uint256 flag
    ) public initializer {
        __CMTAT_init(deployedWithProxyIrrevocable_, admin, nameIrrevocable, symbolIrrevocable, tokenId, terms, ruleEngine, information, flag);
    }

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    function __CMTAT_init(
        bool deployedWithProxyIrrevocable_,
        address admin,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        string memory tokenId,
        string memory terms,
         IRuleEngine ruleEngine,
        string memory information,
        uint256 flag
    ) internal onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();
        __ERC20_init_unchained(nameIrrevocable, symbolIrrevocable);
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __Pausable_init_unchained();

        /* Internal Modules */
        __Enforcement_init_unchained();
        __Snapshot_init_unchained();
        __Validation_init_unchained(ruleEngine);
        
        /* Wrapper */
        // AuthorizationModule_init_unchained is called firstly due to inheritance
        __AuthorizationModule_init_unchained(admin);
        __BurnModule_init_unchained();
        __MintModule_init_unchained();
        // EnforcementModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __EnforcementModule_init_unchained();
        __ERC20Module_init_unchained(0);
        // PauseModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __PauseModule_init_unchained();
        __ValidationModule_init_unchained();
        __SnasphotModule_init_unchained();
        
        /* Other modules */
        __Base_init_unchained(tokenId, terms, information, flag);

         /* own function */
        __CMTAT_init_unchained(deployedWithProxyIrrevocable_);
    }

    function __CMTAT_init_unchained(bool deployedWithProxyIrrevocable_) internal onlyInitializing {
        deployedWithProxy = deployedWithProxyIrrevocable_;
    }

    function decimals()
        public
        view
        virtual
        override(ERC20Upgradeable, ERC20BaseModule)
        returns (uint8)
    {
        return ERC20BaseModule.decimals();
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override(ERC20Upgradeable, ERC20BaseModule) returns (bool) {
        return ERC20BaseModule.transferFrom(sender, recipient, amount);
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
