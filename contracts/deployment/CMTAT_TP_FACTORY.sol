//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../CMTAT_PROXY.sol";
import "../libraries/FactoryErrors.sol";
import '@openzeppelin/contracts/access/AccessControl.sol';

/**
* @notice Factory to deploy CMTAT with a transparent proxy
* 
*/
contract CMTAT_TP_FACTORY is AccessControl {
    // Public
    /// @dev Role to deploy CMTAT
    bytes32 public constant CMTAT_DEPLOYER_ROLE = keccak256("CMTAT_DEPLOYER_ROLE");
    address public immutable logic;
    address[] public cmtatsList;
    bool public useCustomSalt;
    uint256 public cmtatID;
    /// mapping
    mapping(uint256 => address) private cmtats;
    mapping(bytes32 => bool) private customSaltUsed;
    
    struct CMTAT_ARGUMENT{
        address CMTATAdmin;
        IAuthorizationEngine authorizationEngineIrrevocable;
        string nameIrrevocable;
        string symbolIrrevocable;
        uint8 decimalsIrrevocable;
        string tokenId;
        string terms;
        IRuleEngine ruleEngine;
        string information; 
        uint256 flag;
    }
    event CMTAT(address indexed CMTAT, uint256 id);

  
    /**
    * @param logic_ contract implementation
    * @param factoryAdmin admin
    */
    constructor(address logic_, address factoryAdmin, bool useCustomSalt_) {
        if(logic_ == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForLogicContract();
        }
        if(factoryAdmin == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin();
        }
        if(useCustomSalt_){
            useCustomSalt = useCustomSalt_;
        }
        logic = logic_;
        _grantRole(DEFAULT_ADMIN_ROLE, factoryAdmin);
        _grantRole(CMTAT_DEPLOYER_ROLE, factoryAdmin);
    }
    
    /**
    * @notice deploy a transparent proxy with a proxy admin contract
    */
    function deployCMTAT(
        bytes32 deploymentSalt,
        address proxyAdminOwner,
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument
    ) public onlyRole(CMTAT_DEPLOYER_ROLE) returns(TransparentUpgradeableProxy cmtat)   {
        //bytes32 saltBytes = _checkAndDetermineDeploymentSalt(deploymentSalt);
        bytes memory bytecode = _getBytecode(proxyAdminOwner,
        // CMTAT function initialize
        cmtatArgument);
        cmtat = _deployBytecode(bytecode, _checkAndDetermineDeploymentSalt(deploymentSalt));
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
        bytes32 hash = computeHash(deploymentSalt, bytecode);
        return address (uint160(uint(hash)));
    }
    
    /**
    * @param salt used by create2 to compute the contract address
    * @param bytecode contract bytecode used by create2 to compute the contract address
    */
    function computeHash(bytes32 salt, bytes memory bytecode) public view returns(bytes32 hash) {
        hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), salt, keccak256(bytecode)
          )
        );
    }

    /**
    * @notice get CMTAT proxy address
    *
    */
    function CMTATProxyAddress(uint256 cmtatID_) external view returns (address) {
        return cmtats[cmtatID_];
    }
    
    /**
    * @param deploymentSalt salt for deployment
    * @dev 
    * if useCustomSalt is at false, the salt used is the current value of cmtatId
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
            saltBytes = bytes32(keccak256(abi.encodePacked(cmtatID)));
        }
    }

    /**
    * @notice Deploy CMTAT and push the created CMTAT in the list
    */
    function _deployBytecode(bytes memory bytecode, bytes32 saltBytes) internal returns (TransparentUpgradeableProxy cmtat) {
                    cmtat = TransparentUpgradeableProxy(payable(_deploy(bytecode, saltBytes)));
                    cmtats[cmtatID] = address(cmtat);
                    emit CMTAT(address(cmtat), cmtatID);
                    ++cmtatID;
                    cmtatsList.push(address(cmtat));
                    return cmtat;
     }

    
    /**
    * @notice return the smart contract bytecode
    */
     function _getBytecode( address proxyAdminOwner,
        // CMTAT function initialize
        CMTAT_ARGUMENT calldata cmtatArgument) internal view returns(bytes memory bytecode) {
        bytes memory implementation = _encodeImplementationArgument(
            cmtatArgument.CMTATAdmin,
            cmtatArgument.authorizationEngineIrrevocable,
            cmtatArgument.nameIrrevocable,
            cmtatArgument.symbolIrrevocable,
            cmtatArgument.decimalsIrrevocable,
            cmtatArgument.tokenId,
            cmtatArgument.terms,
            cmtatArgument.ruleEngine,
            cmtatArgument.information,
            cmtatArgument.flag
            );
        bytecode = abi.encodePacked(type(TransparentUpgradeableProxy).creationCode,  abi.encode(logic, proxyAdminOwner, implementation));
     }


    function _encodeImplementationArgument(  address admin,
        IAuthorizationEngine authorizationEngineIrrevocable,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        uint8 decimalsIrrevocable,
        string memory tokenId_,
        string memory terms_,
        IRuleEngine ruleEngine_,
        string memory information_, 
        uint256 flag_) internal pure returns(bytes memory){
        return  abi.encodeWithSelector(
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
        );
    }

    /**
    * @notice deploy smart contract with create2
    */
    function _deploy(bytes memory bytecode, bytes32 _salt) internal returns (address contractAddress) {
        assembly {
            contractAddress := create2(0, add(bytecode, 0x20), mload(bytecode), _salt)
            if iszero(extcodesize(contractAddress)) {
                revert(0, 0)
            }
        }
    }
}