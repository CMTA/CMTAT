//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {CMTATBaseOption} from "../modules/CMTATBaseOption.sol";
import {MetaTxModule} from "../modules/wrapper/options/MetaTxModule.sol";
import {ICMTATConstructor, CMTATBase} from "../modules/CMTATBase.sol";

/**
* @title CMTAT version for a proxy deployment with UUPS proxy
*/
contract CMTATUpgradeableUUPS is CMTATBaseOption, UUPSUpgradeable  {
    bytes32 public constant PROXY_UPGRADE_ROLE = keccak256("PROXY_UPGRADE_ROLE");
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) MetaTxModule(forwarderIrrevocable) {
        // Disable the possibility to initialize the implementation
        _disableInitializers();
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice
     * initialize the proxy contract
     * The calls to this function will revert if the contract was deployed without a proxy
     * @param admin address of the admin of contract (Access Control)
     * @param ERC20Attributes_ ERC20 name, symbol and decimals
     * @param baseModuleAttributes_ tokenId, terms, information
     * @param engines_ external contract
     */
    function initialize(  address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.BaseModuleAttributes memory baseModuleAttributes_,
        ICMTATConstructor.Engine memory engines_ ) public override initializer {
        CMTATBase.initialize( admin,
            ERC20Attributes_,
            baseModuleAttributes_,
            engines_);
        __UUPSUpgradeable_init_unchained();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _authorizeUpgrade(address) internal override onlyRole(PROXY_UPGRADE_ROLE) {}
}
