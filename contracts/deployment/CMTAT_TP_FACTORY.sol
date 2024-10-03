//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../CMTAT_PROXY.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "./libraries/CMTATFactoryInvariant.sol";
import "./libraries/CMTATFactoryBase.sol";


/**
* @notice Factory to deploy CMTAT with a transparent proxy
* 
*/
contract CMTAT_TP_FACTORY is CMTATFactoryBase {

    /**
    * @param logic_ contract implementation, cannot be zero
    * @param factoryAdmin admin
    * @param useCustomSalt_ custom salt with create2 or not
    */
    constructor(address logic_, address factoryAdmin, bool useCustomSalt_) CMTATFactoryBase(logic_, factoryAdmin,useCustomSalt_){}

    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
        /**
    * @notice deploy a transparent proxy with a proxy admin contract
    */
    function deployCMTAT(
        bytes32 deploymentSaltInput,
        address proxyAdminOwner,
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument
    ) public onlyRole(CMTAT_DEPLOYER_ROLE) returns(TransparentUpgradeableProxy cmtat)   {
        bytes32 deploymentSalt = _checkAndDetermineDeploymentSalt(deploymentSaltInput);
        bytes memory bytecode = _getBytecode(proxyAdminOwner,
        // CMTAT function initialize
        cmtatArgument);
        cmtat = _deployBytecode(bytecode,  deploymentSalt);
        
        return cmtat;
    }

    /**
    * @param deploymentSalt salt for the deployment
    * @param proxyAdminOwner admin of the proxy
    * @param cmtatArgument argument for the function initialize
    * @notice get the proxy address depending on a particular salt
    */
    function computedProxyAddress( 
        bytes32 deploymentSalt,
        address proxyAdminOwner,
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument) public view returns (address) {
        bytes memory bytecode =  _getBytecode(proxyAdminOwner,
        // CMTAT function initialize
        cmtatArgument);
        return Create2.computeAddress(deploymentSalt,  keccak256(bytecode), address(this) );
    }


    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/


    /**
    * @notice Deploy CMTAT and push the created CMTAT in the list
    */
    function _deployBytecode(bytes memory bytecode, bytes32  deploymentSalt) internal returns (TransparentUpgradeableProxy cmtat) {
                    address cmtatAddress = Create2.deploy(0, deploymentSalt, bytecode);
                    cmtat = TransparentUpgradeableProxy(payable(cmtatAddress));
                    cmtats[cmtatCounterId] = address(cmtat);
                    emit CMTAT(address(cmtat), cmtatCounterId);
                    ++cmtatCounterId;
                    cmtatsList.push(address(cmtat));
                    return cmtat;
     }

    
    /**
    * @notice return the smart contract bytecode
    */
     function _getBytecode( address proxyAdminOwner,
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument) internal view returns(bytes memory bytecode) {
        bytes memory implementation = abi.encodeWithSelector(
            CMTAT_PROXY(address(0)).initialize.selector,
                  cmtatArgument.CMTATAdmin,
                    cmtatArgument.ERC20Attributes,
                cmtatArgument.baseModuleAttributes,
                cmtatArgument.engines
        );
        bytecode = abi.encodePacked(type(TransparentUpgradeableProxy).creationCode,  abi.encode(logic, proxyAdminOwner, implementation));
     }
}