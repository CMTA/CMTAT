//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
/* ==== Module === */
import {DebtEngineModule, DebtModule, ICMTATDebt} from "./options/DebtEngineModule.sol";
import {ERC20CrossChainModule, CMTAT_BASE} from "./options/ERC20CrossChainModule.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {AccessControlUpgradeable} from "./security/AuthorizationModule.sol";
import {MetaTxModule, ERC2771ContextUpgradeable} from "./wrapper/extensions/MetaTxModule.sol";
/**
* @title Extend CMTAT Base
*/
abstract contract CMTAT_BASE_EXTEND is  ERC20CrossChainModule,DebtEngineModule, MetaTxModule {

    function debt() public view virtual override(DebtEngineModule, DebtModule) returns(DebtBase memory debtBaseResult){
        return DebtEngineModule.debt();
        
    }
        /*//////////////////////////////////////////////////////////////
                            METAXTX MODULE
    //////////////////////////////////////////////////////////////*/
       /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgSender()
        internal
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _contextSuffixLength() internal view 
    override(ContextUpgradeable, ERC2771ContextUpgradeable)
    returns (uint256) {
         return ERC2771ContextUpgradeable._contextSuffixLength();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgData()
        internal
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }

    /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, ERC20CrossChainModule) returns (bool) {
        return AccessControlUpgradeable.supportsInterface(interfaceId) || ERC20CrossChainModule.supportsInterface(interfaceId);
    }
}
