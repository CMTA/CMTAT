//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
/* ==== Module === */
import {CMTATBaseERC20CrossChain, CMTATBase} from "./3_CMTATBaseERC20CrossChain.sol";
import {AccessControlUpgradeable, AuthorizationModule, CMTATBaseCommon} from "./0_CMTATBaseCommon.sol";
import {CMTATBase} from "./2_CMTATBase.sol";
import {MetaTxModule, ERC2771ContextUpgradeable} from "./wrapper/options/MetaTxModule.sol";
/**
* @title Extend CMTAT Base with option modules
*/
abstract contract CMTATBaseOption is CMTATBaseERC20CrossChain, MetaTxModule {
    /*//////////////////////////////////////////////////////////////
                            METAXTX MODULE
    //////////////////////////////////////////////////////////////*/
       /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgSender()
        internal virtual
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (address sender)
    {
        return ERC2771ContextUpgradeable._msgSender();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _contextSuffixLength() internal virtual view 
    override(ContextUpgradeable, ERC2771ContextUpgradeable)
    returns (uint256) {
         return ERC2771ContextUpgradeable._contextSuffixLength();
    }

    /**
     * @dev This surcharge is not necessary if you do not use the MetaTxModule
     */
    function _msgData()
        internal virtual
        view
        override(ContextUpgradeable, ERC2771ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }
}
