// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../CMTAT_PROXY.sol";
import '@openzeppelin/contracts/access/AccessControl.sol';
/**
* @notice Factory to deploy transparent proxy
* 
*/
contract CMTAT_TP_FACTORY is AccessControl {
    // Private
    mapping(uint256 => address) private cmtats;
    uint256 private cmtatID;
    event CMTAT(address indexed CMTAT, uint256 id);
    // Public
    /// @dev Role to deploy CMTAT
    bytes32 public constant CMTAT_DEPLOYER_ROLE = keccak256("CMTAT_DEPLOYER_ROLE");
    address public immutable logic;
    address[] public cmtatsList;

    /**
    * @param logic_ contract implementation
    * @param factoryAdmin admin
    */
    constructor(address logic_, address factoryAdmin) {
        logic = logic_;
        _grantRole(DEFAULT_ADMIN_ROLE, factoryAdmin);
        _grantRole(CMTAT_DEPLOYER_ROLE, factoryAdmin);
    }

    function deployCMTAT(
        address proxyAdminOwner,
        // CMTAT function initialize
        address admin,
        IAuthorizationEngine authorizationEngineIrrevocable,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        uint8 decimalsIrrevocable,
        string memory tokenId_,
        string memory terms_,
        IRuleEngine ruleEngine_,
        string memory information_, 
        uint256 flag_
    ) public onlyRole(CMTAT_DEPLOYER_ROLE) returns(TransparentUpgradeableProxy cmtat)   {
        cmtat = new TransparentUpgradeableProxy(
            logic,
            proxyAdminOwner,
            abi.encodeWithSelector(
                CMTAT_PROXY(address(0)).initialize.selector,
                    admin,
                    authorizationEngineIrrevocable,
                    nameIrrevocable,
                    symbolIrrevocable,
                    decimalsIrrevocable,
                    tokenId_,
                    terms_,
                    ruleEngine_,
                    information_, 
                    flag_
            )
        );
        cmtats[cmtatID] = address(cmtat);
        emit CMTAT(address(cmtat), cmtatID);
        cmtatID++;
        cmtatsList.push(address(cmtat));
        return cmtat;
    }

    /**
    * @notice get CMTAT proxy address
    *
    */
    function getAddress(uint256 cmtatID_) external view returns (address) {
        return cmtats[cmtatID_];
    }
}