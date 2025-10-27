// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {CMTATBaseERC2771} from "../modules/4_CMTATBaseERC2771.sol";
import {CMTATBaseRuleEngine} from "../modules/1_CMTATBaseRuleEngine.sol";
import {ERC2771Module} from "../modules/wrapper/options/ERC2771Module.sol";
import {ICMTATConstructor} from "../interfaces/technical/ICMTATConstructor.sol";

/**
* @title CMTAT version for a proxy deployment with UUPS proxy
*/
contract CMTATUpgradeableUUPS is CMTATBaseERC2771, UUPSUpgradeable  {
    bytes32 public constant PROXY_UPGRADE_ROLE = keccak256("PROXY_UPGRADE_ROLE");
    /**
     * @notice Contract version for the deployment with a proxy
     * @param forwarderIrrevocable address of the forwarder, required for the gasless support
     */
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address forwarderIrrevocable
    ) ERC2771Module(forwarderIrrevocable) {
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
     * @param extraInformationAttributes_ tokenId, terms, information
     * @param engines_ external contract
     */
    function initialize(address admin,
        ICMTATConstructor.ERC20Attributes memory ERC20Attributes_,
        ICMTATConstructor.ExtraInformationAttributes memory extraInformationAttributes_,
        ICMTATConstructor.Engine memory engines_ ) public override initializer {
        CMTATBaseRuleEngine._initialize( admin,
            ERC20Attributes_,
            extraInformationAttributes_,
            engines_);
        __UUPSUpgradeable_init_unchained();
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _authorizeUpgrade(address newImplementation) internal virtual override(UUPSUpgradeable) onlyRole(PROXY_UPGRADE_ROLE) {}
}
