//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";
import "./wrapper/mandatory/BaseModule.sol";
import "./wrapper/mandatory/BurnModule.sol";
import "./wrapper/mandatory/MintModule.sol";
import "./wrapper/mandatory/EnforcementModule.sol";
import "./wrapper/mandatory/ERC20BaseModule.sol";
import "./wrapper/mandatory/SnapshotModule.sol";
import "./wrapper/mandatory/PauseModule.sol";
import "./wrapper/optional/ValidationModule.sol";
import "./wrapper/optional/MetaTxModule.sol";
import "./wrapper/optional/DebtModule/DebtBaseModule.sol";
import "./wrapper/optional/DebtModule/CreditEvents.sol";
import "./security/AuthorizationModule.sol";
import "../interfaces/IRuleEngine.sol";

abstract contract CMTAT_BASE is
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
        require(ValidationModule.validateTransfer(from, to, amount), "CMTAT: transfer rejected by validation module");
        // We call the SnapshotModule only if the transfer is valid
        SnapshotModuleInternal._beforeTokenTransfer(from, to, amount);
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