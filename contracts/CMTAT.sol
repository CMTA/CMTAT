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
import "./modules/wrapper/optional/DebtModule/DebtBaseModule.sol";
import "./modules/wrapper/optional/DebtModule/CreditEvents.sol";
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
    DebtBaseModule,
    CreditEvents
{
    /** 
    @notice create the contract
    @param forwarderIrrevocable address of the forwarder, required for the gasless support
    @param deployedWithProxyIrrevocable_ true if the contract is deployed with a proxy, false otherwise
    @param admin address of the admin of contract (Access Control)
    @param nameIrrevocable name of the token
    @param symbolIrrevocable name of the symbol
    @param tokenId name of the tokenId
    @param terms terms associated with the token
    @param ruleEngine address of the ruleEngine to apply rules to transfers
    @param information additional information to describe the token
    @param flag add information under the form of bit(0, 1)
    */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable,
        bool deployedWithProxyIrrevocable_,
        address admin,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        string memory tokenId,
        string memory terms,
        IRuleEngine ruleEngine,
        string memory information,
        uint256 flag
    ) MetaTxModule(forwarderIrrevocable) {
        if (!deployedWithProxyIrrevocable_) {
            // Initialize the contract to avoid front-running
            // Warning : do not initialize the proxy
            initialize(
                deployedWithProxyIrrevocable_,
                admin,
                nameIrrevocable,
                symbolIrrevocable,
                tokenId,
                terms,
                ruleEngine,
                information,
                flag
            );
        } else {
            // Initialize the variable for the implementation
            deployedWithProxy = true;
            // Disable the possibility to initialize the implementation
            _disableInitializers();
        }
    }

    /**
    @notice 
    initialize the proxy contract
    The calls to this function will revert if the contract was deployed without a proxy
    */
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
        __CMTAT_init(
            deployedWithProxyIrrevocable_,
            admin,
            nameIrrevocable,
            symbolIrrevocable,
            tokenId,
            terms,
            ruleEngine,
            information,
            flag
        );
    }

    /**
    @dev calls the different initialize functions from the different modules
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
        __DebtBaseModule_init_unchained();
        __CreditEvents_init_unchained();
        __Base_init_unchained(tokenId, terms, information, flag);

        /* own function */
        __CMTAT_init_unchained(deployedWithProxyIrrevocable_);
    }

    /**
    @param deployedWithProxyIrrevocable_ true if the contract is deployed with a proxy, false otherwise
    */
    function __CMTAT_init_unchained(
        bool deployedWithProxyIrrevocable_
    ) internal onlyInitializing {
        deployedWithProxy = deployedWithProxyIrrevocable_;
    }

    /**
    @notice Returns the number of decimals used to get its user representation.
    */
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
    )
        public
        virtual
        override(ERC20Upgradeable, ERC20BaseModule)
        returns (bool)
    {
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

        require(
            validateTransfer(from, to, amount),
            "CMTAT: transfer rejected by validation module"
        );
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
