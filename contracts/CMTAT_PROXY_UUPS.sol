//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
import "../openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import "./modules/CMTAT_BASE.sol";

contract CMTAT_PROXY_UUPS is CMTAT_BASE, UUPSUpgradeable {
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
    function initialize(  address admin,
        IAuthorizationEngine authorizationEngineIrrevocable,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        uint8 decimalsIrrevocable,
        string memory tokenId_,
        string memory terms_,
        IRuleEngine ruleEngine_,
        string memory information_, 
        uint256 flag_) public override initializer {
        CMTAT_BASE.initialize( admin,
            authorizationEngineIrrevocable, 
            nameIrrevocable,
            symbolIrrevocable,
            decimalsIrrevocable,
            tokenId_,
            terms_,
            ruleEngine_,
            information_,
            flag_);
        __UUPSUpgradeable_init_unchained();
    }

    function _authorizeUpgrade(address) internal override onlyRole("DEFAULT_ADMIN_ROLE") {}

    uint256[50] private __gap;
}
