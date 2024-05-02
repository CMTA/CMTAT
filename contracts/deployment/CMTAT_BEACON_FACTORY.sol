//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import '@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol';
import "../CMTAT_PROXY.sol";
import "../modules/CMTAT_BASE.sol";
import "../libraries/FactoryErrors.sol";
import '@openzeppelin/contracts/access/AccessControl.sol';

/**
* @notice Factory to deploy beacon proxy
* 
*/
contract CMTAT_BEACON_FACTORY is AccessControl {
    // Private
    mapping(uint256 => address) private cmtats;
    uint256 private cmtatCounterId;
    // public
    /// @dev Role to deploy CMTAT
    bytes32 public constant CMTAT_DEPLOYER_ROLE = keccak256("CMTAT_DEPLOYER_ROLE");
    UpgradeableBeacon public immutable beacon;
    address[] public cmtatsList;
    event CMTAT(address indexed CMTAT, uint256 id);

    /**
    * @param implementation_ contract implementation
    * @param factoryAdmin admin
    * @param beaconOwner owner
    */
    constructor(address implementation_, address factoryAdmin, address beaconOwner) {
        if(factoryAdmin == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin();
        }
        if(beaconOwner == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForBeaconOwner();
        }
        if(implementation_ == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForLogicContract();
        }
        beacon = new UpgradeableBeacon(implementation_, beaconOwner);
        _grantRole(DEFAULT_ADMIN_ROLE, factoryAdmin);
        _grantRole(CMTAT_DEPLOYER_ROLE, factoryAdmin);
    }

    /**
    * @notice deploy CMTAT with a beacon proxy
    * 
    */
    function deployCMTAT(
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
    ) public onlyRole(CMTAT_DEPLOYER_ROLE) returns(BeaconProxy cmtat)   {
        cmtat = new BeaconProxy(
            address(beacon),
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
        cmtats[cmtatCounterId] = address(cmtat);
        emit CMTAT(address(cmtat), cmtatCounterId);
        cmtatCounterId++;
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

    /**
    * @notice get the implementation address from the beacon
    * @return implementation address
    */
    function implementation() public view returns (address) {
        return beacon.implementation();
    }
}