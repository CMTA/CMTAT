// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import '@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol';
import "./proxy/Beacon.sol";
import "../CMTAT_PROXY.sol";
import '@openzeppelin/contracts/access/AccessControl.sol';
contract CMTAT_BEACON_FACTORY is AccessControl {
    /// @dev Role to deploy CMTAT
    bytes32 public constant CMTAT_DEPLOYER = keccak256("CMTAT_DEPLOYER ");
    mapping(uint256 => address) private cmtats;
    address[] public cmtatsList;
    uint256 cmtatID;
    UpgradeableBeacon immutable beacon;
    event CMTAT(address indexed CMTAT, uint256);

    /**
    * @param implementation_ contract implementation
    * @param factoryAdmin admin
    * @param beaconOwner owner
    */
    constructor(address implementation_, address factoryAdmin, address beaconOwner) {
        beacon = new UpgradeableBeacon(implementation_, beaconOwner);
        _grantRole(DEFAULT_ADMIN_ROLE, factoryAdmin);
        _grantRole(CMTAT_DEPLOYER, factoryAdmin);
    }

    function deployCMTAT(
        address forwarderIrrevocable,
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
    ) public onlyRole(CMTAT_DEPLOYER) returns(BeaconProxy cmtat)   {
        cmtat = new BeaconProxy(
            address(beacon),
            abi.encodeWithSelector(
                CMTAT_PROXY(address(new CMTAT_PROXY(forwarderIrrevocable))).initialize.selector,
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
        return
    }

    /**
    * @notice get CMTAT proxy address
    *
    */
    function getAddress(uint256 cmtatID_) external view returns (address) {
        return cmtats[cmtatID_];
    }

    /**
    * @notice get beacon address
    * @return beacon address
    */
    function getBeacon() public view returns (address) {
        return address(beacon);
    }

    /**
    * @notice get the implementation address from the beacon
    * @return implementation address
    */
    function implementation() public view returns (address) {
        return beacon.implementation();
    }
}