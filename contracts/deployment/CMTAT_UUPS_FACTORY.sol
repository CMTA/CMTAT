//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../CMTAT_PROXY_UUPS.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import "./libraries/CMTATFactoryInvariant.sol";
import "./libraries/CMTATFactoryBase.sol";


/**
* @notice Factory to deploy CMTAT with a UUPS proxy
* 
*/
contract CMTAT_UUPS_FACTORY is CMTATFactoryBase {
    /**
    * @param logic_ contract implementation
    * @param factoryAdmin admin
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
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument
    ) public onlyRole(CMTAT_DEPLOYER_ROLE) returns(ERC1967Proxy cmtat)   {
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

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @notice Deploy CMTAT and push the created CMTAT in the list
    */
    function _deployBytecode(bytes memory bytecode, bytes32  deploymentSalt) internal returns (ERC1967Proxy cmtat) {
                    address cmtatAddress = Create2.deploy(0, deploymentSalt, bytecode);
                    cmtat = ERC1967Proxy(payable(cmtatAddress));
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
        bytes memory implementation = abi.encodeWithSelector(
            CMTAT_PROXY_UUPS(address(0)).initialize.selector,
                  cmtatArgument.CMTATAdmin,
                    cmtatArgument.ERC20Attributes,
                cmtatArgument.baseModuleAttributes,
                cmtatArgument.engines
        );
        bytecode = abi.encodePacked(type(ERC1967Proxy).creationCode,  abi.encode(logic, implementation));
     }
}