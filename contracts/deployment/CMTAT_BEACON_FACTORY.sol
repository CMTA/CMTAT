//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import '@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol';
import "../CMTAT_PROXY.sol";
import "../modules/CMTAT_BASE.sol";
import "./libraries/CMTATFactoryRoot.sol";


/**
* @notice Factory to deploy beacon proxy
* 
*/
contract CMTAT_BEACON_FACTORY is AccessControl, CMTATFactoryRoot {
    // public
    UpgradeableBeacon public immutable beacon;
    /**
    * @param implementation_ contract implementation
    * @param factoryAdmin admin
    * @param beaconOwner owner
    */
    constructor(address implementation_, address factoryAdmin, address beaconOwner, bool useCustomSalt_)CMTATFactoryRoot(factoryAdmin, useCustomSalt_) {
        if(beaconOwner == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForBeaconOwner();
        }
        if(implementation_ == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForLogicContract();
        }
        beacon = new UpgradeableBeacon(implementation_, beaconOwner);
    }

    /**
    * @notice deploy CMTAT with a beacon proxy
    * 
    */
    function deployCMTAT(
         bytes32 deploymentSaltInput,
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument
    ) public onlyRole(CMTAT_DEPLOYER_ROLE) returns(BeaconProxy cmtat)   {
        bytes32 deploymentSalt = _checkAndDetermineDeploymentSalt(deploymentSaltInput);
        bytes memory bytecode = _getBytecode(
        // CMTAT function initialize
        cmtatArgument);
        cmtat = _deployBytecode(bytecode,  deploymentSalt);
        return cmtat;
    }

    /**
    * @param deploymentSalt salt for the deployment
    * @param cmtatArgument argument for the function initialize
    * @notice get the proxy address depending on a particular salt
    */
    function computedProxyAddress( 
        bytes32 deploymentSalt,
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument) public view returns (address) {
        bytes memory bytecode =  _getBytecode(
        // CMTAT function initialize
        cmtatArgument);
        return Create2.computeAddress(deploymentSalt,  keccak256(bytecode), address(this) );
    }

    /**
    * @notice Deploy CMTAT and push the created CMTAT in the list
    */
    function _deployBytecode(bytes memory bytecode, bytes32  deploymentSalt) internal returns (BeaconProxy cmtat) {
                    address cmtatAddress = Create2.deploy(0, deploymentSalt, bytecode);
                    cmtat = BeaconProxy(payable(cmtatAddress));
                    cmtats[cmtatCounterId] = address(cmtat);
                    emit CMTAT(address(cmtat), cmtatCounterId);
                    ++cmtatCounterId;
                    cmtatsList.push(address(cmtat));
                    return cmtat;
     }

    
    /**
    * @notice return the smart contract bytecode
    */
     function _getBytecode( 
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument) internal view returns(bytes memory bytecode) {
        bytes memory _implementation = abi.encodeWithSelector(
            CMTAT_PROXY(address(0)).initialize.selector,
            cmtatArgument.CMTATAdmin,
            cmtatArgument.ERC20Attributes,
            cmtatArgument.baseModuleAttributes,
            cmtatArgument.engines
        );
        bytecode = abi.encodePacked(type(BeaconProxy).creationCode,  abi.encode(address(beacon), _implementation));
     }

    /**
    * @notice get the implementation address from the beacon
    * @return implementation address
    */
    function implementation() public view returns (address) {
        return beacon.implementation();
    }
}