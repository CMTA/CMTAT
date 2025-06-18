//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
/* ==== Module === */
import {AccessControlUpgradeable, CMTATBase, CMTATBaseOption, CMTATBaseERC20CrossChain} from "./4_CMTATBaseOption.sol";
import {CMTATBase} from "./2_CMTATBase.sol";
import {ERC7551Module} from "./wrapper/options/ERC7551Module.sol";
/**
* @title Extend CMTAT Base Option with ERC7551Module
*/
abstract contract CMTATBaseERC7551 is CMTATBaseOption, ERC7551Module {
    // nothing to do
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable, CMTATBase) returns (bool) {
        return CMTATBase.hasRole(role, account);
    }

     /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, CMTATBaseERC20CrossChain) returns (bool) {
        return AccessControlUpgradeable.supportsInterface(interfaceId) || CMTATBaseERC20CrossChain.supportsInterface(interfaceId);
    }

        /*//////////////////////////////////////////////////////////////
                            METAXTX MODULE
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc CMTATBaseOption
    */
    function _msgSender()
        internal
        view
        override(ContextUpgradeable, CMTATBaseOption)
        returns (address sender)
    {
        return CMTATBaseOption._msgSender();
    }

    /**
    * @inheritdoc CMTATBaseOption
    */
    function _contextSuffixLength() internal view 
    override(ContextUpgradeable, CMTATBaseOption)
    returns (uint256) {
         return CMTATBaseOption._contextSuffixLength();
    }

    /**
    * @inheritdoc CMTATBaseOption
    */
    function _msgData()
        internal
        view
        override(ContextUpgradeable, CMTATBaseOption)
        returns (bytes calldata)
    {
        return CMTATBaseOption._msgData();
    }

}
