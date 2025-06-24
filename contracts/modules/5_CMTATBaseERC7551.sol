//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.20;
/* ==== OpenZeppelin === */
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {AccessControlUpgradeable} from "./wrapper/security/AccessControlModule.sol";
/* ==== Module === */
import {CMTATBaseERC1404, CMTATBaseERC2771, CMTATBaseERC20CrossChain} from "./4_CMTATBaseERC2771.sol";
import {ERC7551Module} from "./wrapper/options/ERC7551Module.sol";
/**
* @title Extend CMTAT Base Option with ERC7551Module
*/
abstract contract CMTATBaseERC7551 is CMTATBaseERC2771, ERC7551Module {
    /*//////////////////////////////////////////////////////////////
                            PUBLIC/EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /* ============ View functions ============ */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override(AccessControlUpgradeable, CMTATBaseERC1404) returns (bool) {
        return CMTATBaseERC1404.hasRole(role, account);
    }

     /**
     * 
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlUpgradeable, CMTATBaseERC20CrossChain) returns (bool) {
        return AccessControlUpgradeable.supportsInterface(interfaceId) || CMTATBaseERC20CrossChain.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                           ERC2771 MODULE
    //////////////////////////////////////////////////////////////*/
    /**
    * @inheritdoc CMTATBaseERC2771
    */
    function _msgSender()
        internal
        view
        override(ContextUpgradeable, CMTATBaseERC2771)
        returns (address sender)
    {
        return CMTATBaseERC2771._msgSender();
    }

    /**
    * @inheritdoc CMTATBaseERC2771
    */
    function _contextSuffixLength() internal view 
    override(ContextUpgradeable, CMTATBaseERC2771)
    returns (uint256) {
         return CMTATBaseERC2771._contextSuffixLength();
    }

    /**
    * @inheritdoc CMTATBaseERC2771
    */
    function _msgData()
        internal
        view
        override(ContextUpgradeable, CMTATBaseERC2771)
        returns (bytes calldata)
    {
        return CMTATBaseERC2771._msgData();
    }

}
