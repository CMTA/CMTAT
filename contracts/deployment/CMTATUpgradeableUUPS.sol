// SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {CMTATBaseERC2771} from "../modules/4_CMTATBaseERC2771.sol";
import {ERC2771Module} from "../modules/wrapper/options/ERC2771Module.sol";

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

    /*//////////////////////////////////////////////////////////////
                            INTERNAL/PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _authorizeUpgrade(address newImplementation) internal virtual override(UUPSUpgradeable) onlyRole(PROXY_UPGRADE_ROLE) {}
}
