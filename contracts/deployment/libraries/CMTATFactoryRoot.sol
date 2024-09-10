//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "../../libraries/FactoryErrors.sol";
import '@openzeppelin/contracts/access/AccessControl.sol';
import "./CMTATFactoryInvariant.sol";
/**
* @notice Code common to Beacon, TP and UUPS factory
* 
*/
abstract contract CMTATFactoryRoot is AccessControl, CMTATFactoryInvariant {
    /* ============ State Variables ============ */
    // Public
    address[] public cmtatsList;
    bool immutable public useCustomSalt;
    uint256 public cmtatCounterId;
    /// mapping
    mapping(uint256 => address) internal cmtats;
    mapping(bytes32 => bool) internal customSaltUsed;
    
    /* ============ Constructor ============ */
    /**
    * @param factoryAdmin admin
    */
    constructor(address factoryAdmin, bool useCustomSalt_) {
        if(factoryAdmin == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin();
        }
        if(useCustomSalt_){
            useCustomSalt = useCustomSalt_;
        }
        _grantRole(DEFAULT_ADMIN_ROLE, factoryAdmin);
        _grantRole(CMTAT_DEPLOYER_ROLE, factoryAdmin);
    }


    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
    * @notice get CMTAT proxy address
    *
    */
    function CMTATProxyAddress(uint256 cmtatCounterId_) external view returns (address) {
        return cmtats[cmtatCounterId_];
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
    * @param deploymentSalt salt for deployment
    * @dev 
    * if useCustomSalt is at false, the salt used is the current value of cmtatCounterId
    */
    function _checkAndDetermineDeploymentSalt(bytes32 deploymentSalt) internal returns(bytes32 saltBytes){
       if(useCustomSalt){
            if(customSaltUsed[deploymentSalt]){
                revert FactoryErrors.CMTAT_Factory_SaltAlreadyUsed();
            }else {
                customSaltUsed[deploymentSalt] = true;
                saltBytes = deploymentSalt;
            }
        }else{
            saltBytes = bytes32(keccak256(abi.encodePacked(cmtatCounterId)));
        }
    }
}