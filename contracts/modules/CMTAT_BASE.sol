//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;

// required OZ imports here
import "../../openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "../../openzeppelin-contracts-upgradeable/contracts/utils/ContextUpgradeable.sol";

import "./wrapper/core/BaseModule.sol";
import "./wrapper/core/ERC20BurnModule.sol";
import "./wrapper/core/ERC20MintModule.sol";
import "./wrapper/core/EnforcementModule.sol";
import "./wrapper/core/ERC20BaseModule.sol";
import "./wrapper/core/PauseModule.sol";
/*
SnapshotModule:
Add this import in case you add the SnapshotModule
import "./wrapper/optional/SnapshotModule.sol";
*/
import "./wrapper/controllers/ValidationModule.sol";
import "./wrapper/extensions/MetaTxModule.sol";
import "./wrapper/extensions/DebtModule/DebtBaseModule.sol";
import "./wrapper/extensions/DebtModule/CreditEventsModule.sol";
import "./security/AuthorizationModule.sol";

import "../libraries/Errors.sol";

abstract contract CMTAT_BASE is
    Initializable,
    ContextUpgradeable,
    BaseModule,
    PauseModule,
    ERC20MintModule,
    ERC20BurnModule,
    EnforcementModule,
    ValidationModule,
    MetaTxModule,
    ERC20BaseModule,
    // ERC20SnapshotModule,
    DebtBaseModule,
    CreditEventsModule
{
    /**
     * @notice
     * initialize the proxy contract
     * The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param nameIrrevocable name of the token
     * @param symbolIrrevocable name of the symbol
     * @param decimalsIrrevocable number of decimals of the token, must be 0 to be compliant with Swiss law as per CMTAT specifications (non-zero decimal number may be needed for other use cases)
     * @param tokenId_ name of the tokenId
     * @param terms_ terms associated with the token
     * @param ruleEngine_ address of the ruleEngine to apply rules to transfers
     * @param information_ additional information to describe the token
     * @param flag_ add information under the form of bit(0, 1)
     */
    function initialize(
        address admin,
        uint48 initialDelayToAcceptAdminRole, 
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        uint8 decimalsIrrevocable,
        string memory tokenId_,
        string memory terms_,
        IERC1404Wrapper ruleEngine_,
        string memory information_,
        uint256 flag_
    ) public initializer {
        __CMTAT_init(
            admin,
            initialDelayToAcceptAdminRole, 
            nameIrrevocable,
            symbolIrrevocable,
            decimalsIrrevocable,
            tokenId_,
            terms_,
            ruleEngine_,
            information_,
            flag_
        );
    }

    /**
     * @dev calls the different initialize functions from the different modules
     */
    function __CMTAT_init(
        address admin,
        uint48 initialDelayToAcceptAdminRole, 
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        uint8 decimalsIrrevocable,
        string memory tokenId_,
        string memory terms_,
        IERC1404Wrapper ruleEngine_,
        string memory information_,
        uint256 flag_
    ) internal onlyInitializing {
        /* OpenZeppelin library */
        // OZ init_unchained functions are called firstly due to inheritance
        __Context_init_unchained();
        __ERC20_init_unchained(nameIrrevocable, symbolIrrevocable);
        // AccessControlUpgradeable inherits from ERC165Upgradeable
        __ERC165_init_unchained();
        // AuthorizationModule inherits from AccessControlUpgradeable
        __AccessControl_init_unchained();
        __AccessControlDefaultAdminRules_init_unchained(initialDelayToAcceptAdminRole, admin);
        __Pausable_init_unchained();

        /* Internal Modules */
        __Enforcement_init_unchained();
        /*
        SnapshotModule:
        Add this call in case you add the SnapshotModule
        __ERC20Snapshot_init_unchained();
        */
        __Validation_init_unchained(ruleEngine_);

        /* Wrapper */
        // AuthorizationModule_init_unchained is called firstly due to inheritance
        __AuthorizationModule_init_unchained();
        __ERC20BurnModule_init_unchained();
        __ERC20MintModule_init_unchained();
        // EnforcementModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __EnforcementModule_init_unchained();
        __ERC20BaseModule_init_unchained(decimalsIrrevocable);
        // PauseModule_init_unchained is called before ValidationModule_init_unchained due to inheritance
        __PauseModule_init_unchained();
        __ValidationModule_init_unchained();

        /*
        SnapshotModule:
        Add this call in case you add the SnapshotModule
        __ERC20SnasphotModule_init_unchained();
        */

        /* Other modules */
        __DebtBaseModule_init_unchained();
        __CreditEvents_init_unchained();
        __Base_init_unchained(tokenId_, terms_, information_, flag_);

        /* own function */
        __CMTAT_init_unchained();
    }

    function __CMTAT_init_unchained() internal onlyInitializing {
        // no variable to initialize
    }

    /**
     * @notice Returns the number of decimals used to get its user representation.
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

    /**
     * @dev
     * SnapshotModule:
     * - override SnapshotModuleInternal if you add the SnapshotModule
     * e.g. override(ERC20SnapshotModuleInternal, ERC20Upgradeable)
     * - remove the keyword view
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable) {
        if (!ValidationModule.validateTransfer(from, to, amount)) {
            revert Errors.CMTAT_InvalidTransfer(from, to, amount);
        }
        ERC20Upgradeable._update(from, to, amount);
        // We call the SnapshotModule only if the transfer is valid
        /*
        SnapshotModule:
        Add this call in case you add the SnapshotModule
        ERC20SnapshotModuleInternal._update(from, to, amount);
        */
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
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
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
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
