//SPDX-License-Identifier: MPL-2.0

pragma solidity 0.8.17;

import "../../openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";
import "../../openzeppelin-contracts-upgradeable/contracts/utils/Create2Upgradeable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "../modules/CMTAT_BASE.sol";
import "../libraries/FactoryErrors.sol";

/**
* @notice Factory to deploy CMTAT with a transparent proxy
* 
*/
contract CMTAT_FACTORY is AccessControlUpgradeable {
    /* ============ Structs ============ */
    struct CMTAT_data{
        address admin;
        string nameIrrevocable;
        string symbolIrrevocable;
        uint8 decimalsIrrevocable;
        string tokenId;
        string terms;
        string information; 
        uint256 flag;
    }

    /* ============ State Variables ============ */
    /// @notice Role to deploy CMTAT
    bytes32 public constant CMTAT_DEPLOYER_ROLE = keccak256("CMTAT_DEPLOYER_ROLE");
    
    /// @notice Address of the implementation logic
    address public immutable logic;
    
    /// @notice Array to store the deployed CMTAT addresses
    address[] public cmtats;
    
    /// @notice Mapping to store used custom salts
    mapping(bytes32 => bool) private salts;

    /* ============ Events ============ */
    event CMTATdeployed(address indexed CMTAT, uint256 id);

    /**
    * @param logic_ contract implementation
    * @param factoryAdmin admin
    */
    constructor(address logic_, address factoryAdmin) {
        if (logic_ == address(0)) {
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForLogicContract();
        }
        if (factoryAdmin == address(0)) {
            revert  FactoryErrors.CMTAT_Factory_AddressZeroNotAllowedForFactoryAdmin();
        }
        logic = logic_;
        _grantRole(DEFAULT_ADMIN_ROLE, factoryAdmin);
        _grantRole(CMTAT_DEPLOYER_ROLE, factoryAdmin);
    }
    

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/
    /**
    * @param salt deployment's salt
    * @param proxyAdmin admin of the proxy
    * @param cmtatData token data for the function initialize
    * @notice get the proxy address depending on a particular salt
    */
    function computeProxyAddress( 
        bytes32 salt,
        address proxyAdmin,
        CMTAT_data calldata cmtatData
    ) public view returns (address) {
        bytes memory bytecode = _getBytecode(proxyAdmin, cmtatData);
        bytes32 encodedSaltWithSender = keccak256(
            abi.encodePacked(
                msg.sender,
                salt
            )
        );
        return Create2Upgradeable.computeAddress(
            encodedSaltWithSender,
            keccak256(bytecode)
        );
    }

    /*//////////////////////////////////////////////////////////////
                 DEPLOYER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
    * @param salt deployment's salt
    * @param proxyAdmin admin of the proxy
    * @param cmtatData token data used to initialize it
    * @notice deploy a transparent proxy with a proxy admin contract
    */
    function deployCMTAT(
        bytes32 salt,
        address proxyAdmin,
        CMTAT_data calldata cmtatData
    ) public onlyRole(CMTAT_DEPLOYER_ROLE) returns(address cmtat) {
        bytes32 encodedSaltWithSender = keccak256(
            abi.encodePacked(
                msg.sender,
                salt
            )
        );
        if (salts[encodedSaltWithSender]) {
            revert FactoryErrors.CMTAT_Factory_SaltAlreadyUsed();
        }
        salts[encodedSaltWithSender] = true;
        bytes memory bytecode = _getBytecode(proxyAdmin, cmtatData);
        cmtat = _deployBytecode(bytecode, encodedSaltWithSender);
        return cmtat;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _getBytecode(
        address proxyAdmin,
        CMTAT_data calldata cmtatData
    ) internal view returns(bytes memory bytecode) {
        bytes memory implementationData = _encodeImplementationData(
            cmtatData.admin,
            cmtatData.nameIrrevocable,
            cmtatData.symbolIrrevocable,
            cmtatData.decimalsIrrevocable,
            cmtatData.tokenId,
            cmtatData.terms,
            cmtatData.information,
            cmtatData.flag
        );
        bytecode = abi.encodePacked(
            type(TransparentUpgradeableProxy).creationCode,
            abi.encode(
                logic,
                proxyAdmin,
                implementationData
            )
        );
    }

    function _encodeImplementationData( 
        address admin,
        string memory nameIrrevocable,
        string memory symbolIrrevocable,
        uint8 decimalsIrrevocable,
        string memory tokenId_,
        string memory terms_,
        string memory information_, 
        uint256 flag_
    ) internal pure returns(bytes memory) {
        return abi.encodeWithSelector(
            CMTAT_BASE(address(0)).initialize.selector,
            admin,
            nameIrrevocable,
            symbolIrrevocable,
            decimalsIrrevocable,
            tokenId_,
            terms_,
            information_, 
            flag_
        );
    }

    function _deployBytecode(
        bytes memory bytecode,
        bytes32 salt
    ) internal returns (address cmtat) {
        cmtat = Create2Upgradeable.deploy(0, salt, bytecode);
        cmtats.push(address(cmtat));
        emit CMTATdeployed(cmtat, cmtats.length - 1);
        return cmtat;
    }
}