//SPDX-License-Identifier: MPL-2.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../CMTAT_PROXY.sol";
import "../libraries/FactoryErrors.sol";
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
        if(logic_ == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForLogicContract();
        }
        if(factoryAdmin == address(0)){
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin();
        }
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
        bytes memory bytecode = _getBytecode(proxyAdminOwner,
        // CMTAT function initialize
        admin,
        authorizationEngineIrrevocable,
        nameIrrevocable,
        symbolIrrevocable,
        decimalsIrrevocable,
        tokenId_,
        terms_,
        ruleEngine_,
        information_, 
        flag_);
        cmtat = _deployBytecode(bytecode);
        return cmtat;
    }
       // get the computed address before the contract DeployWithCreate2 deployed using Bytecode of contract DeployWithCreate2 and salt specified by the sender

    function getProxyAddress( address proxyAdminOwner,
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
        uint256 flag_, bytes32 salt) public view returns (address) {
        bytes memory bytecode =  _getBytecode(proxyAdminOwner,
        // CMTAT function initialize
        admin,
        authorizationEngineIrrevocable,
        nameIrrevocable,
        symbolIrrevocable,
        decimalsIrrevocable,
        tokenId_,
        terms_,
        ruleEngine_,
        information_, 
        flag_);
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), salt, keccak256(bytecode)
          )
        );
        return address (uint160(uint(hash)));
    }

    function _deployBytecode(bytes memory bytecode) internal returns (TransparentUpgradeableProxy cmtat) {
                    bytes32 saltBytes = bytes32(keccak256(abi.encodePacked(cmtatID)));
                    cmtat = TransparentUpgradeableProxy(payable(_deploy(bytecode, saltBytes)));
                    cmtats[cmtatID] = address(cmtat);
                    emit CMTAT(address(cmtat), cmtatID);
                    cmtatID++;
                    cmtatsList.push(address(cmtat));
                    return cmtat;
     }

     function _getBytecode( address proxyAdminOwner,
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
        uint256 flag_) internal view returns(bytes memory bytecode) {
            bytes memory implementation =  abi.encodeWithSelector(
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
        bytecode = abi.encodePacked(type(TransparentUpgradeableProxy).creationCode,  abi.encode(logic, proxyAdminOwner, implementation));
     }

    function _deploy(bytes memory bytecode, bytes32 _salt) internal returns (address contractAddress) {
        assembly {
            contractAddress := create2(0, add(bytecode, 0x20), mload(bytecode), _salt)
            if iszero(extcodesize(contractAddress)) {
                revert(0, 0)
            }
        }
    }

    /**
    * @notice get CMTAT proxy address
    *
    */
    function getAddress(uint256 cmtatID_) external view returns (address) {
        return cmtats[cmtatID_];
    }
}